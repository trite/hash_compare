defmodule HashCompare do
  @moduledoc """
  Documentation for `HashCompare`.

  This module provides a single function, `compare`, which compares two hashes.
  """

  @doc """
  Compare two hashes. Specifying true for `deep` parameter will scan sub-hashes as well.

  ## Examples
      iex> HashCompare.compare(%{"foo" => "bar"}, %{"foo" => "bar"}, false)
      %{"foo" => {:same, "bar"}}

      iex> HashCompare.compare(%{"foo" => "bar"}, %{"foo" => "tacos"}, false)
      %{"foo" => {:different, %{left: "bar", right: "tacos"}}}

      iex> HashCompare.compare(%{"5" => "42", "almost" => "thesame", "foo" => "bar" }, %{"5" => "42", "almost" => "butnotquite"}, false)
      %{
        "5" => {:same, "42"},
        "almost" => {:different,
          %{left: "thesame", right: "butnotquite"}},
        "foo" => {:left_only, "bar"}
      }
      
      iex> HashCompare.compare(%{"foo" => %{"a" => "b", 1 => 2}}, %{"foo" => %{"a" => "b", 1 => 42}}, false)
      %{
        "foo" => {:different,
          %{
            left: %{1 => 2, "a" => "b"},
            right: %{1 => 42, "a" => "b"}
          }}
      }

      iex> HashCompare.compare(%{"foo" => %{"a" => "b", 1 => 2}}, %{"foo" => %{"a" => "b", 1 => 42}}, true)
      %{
        "foo" => {:sub_map,
          %{
            1 => {:different, %{left: 2, right: 42}},
            "a" => {:same, "b"}
          }}
      }
      
  """
  
  def compare(left, right, deep) do
    left_result = 
      for {k1, v1} <- left, into: %{} do
        if Map.has_key?(right, k1) do
          compare_values(k1, v1, right[k1], deep)
        else
          {k1, {:left_only, v1}}
        end
      end

    right_result =
      for {k2, v2} <- right do
        if Map.has_key?(left_result, k2) do
          {:drop, nil}
        else
          {:keep, {k2, {:right_only, v2}}}
        end
      end
      |> Enum.filter(fn(x) -> elem(x,0) == :keep end)
      |> Enum.map(fn(x) -> elem(x,1) end)
      |> Map.new
      
    Map.merge(left_result, right_result)
  end
  
  defp compare_values(key, left, right, deep) do
    if deep do
      deep_compare_values(key, left, right)
    else
      shallow_compare_values(key, left, right)
    end
  end

  defp deep_compare_values(key, left, right) when is_map(left) and is_map(right) do
    {key, {:sub_map, compare(left, right, true)}} # recurse... TODO: make sure this works right once things are put together
  end

  defp deep_compare_values(key, left, right) do
    simple_compare_values(key, left, right)
  end
  
  defp shallow_compare_values(key, left, right) do
    simple_compare_values(key, left, right)
  end
  
  defp simple_compare_values(key, left, right) do
    if left === right do
      {key, {:same, left}}
    else
      {key, {:different, %{left: left, right: right}}}
    end
  end
end
