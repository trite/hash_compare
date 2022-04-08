defmodule HashCompare do
  @moduledoc """
  Documentation for `HashCompare`.

  This module provides a single function, `compare`, which compares two hashes.
  """

  @doc """
  Compare two hashes.

  ## Examples
      iex> HashCompare.compare(%{"foo" => "bar"}, %{"foo" => "bar"})
      %{
        "are_equal" => true,
        "left_only" => [],
        "right_only" => []
      }

      iex> HashCompare.compare(%{"foo" => "bar"}, %{"foo" => "tacos"})
      %{
        "are_equal" => false,
        "left_only" => [{"foo", "bar"}],
        "right_only" => [{"foo", "tacos"}]
      }

      iex> HashCompare.compare(%{"5" => "42", "almost" => "thesame", "foo" => "bar" }, %{"5" => "42", "almost" => "butnotquite"})
      %{
        "are_equal" => false,
        "left_only" => [{"almost", "thesame"}, {"foo", "bar"}],
        "right_only" => [{"almost", "butnotquite"}]
      }
  """
  def compare(left, right) do
    left_unique = extract_unique(left, right)
    right_unique = extract_unique(right, left)

    %{
      "left_only" => left_unique,
      "right_only" => right_unique,
      "are_equal" => Enum.count(left_unique) == 0 and Enum.count(right_unique) == 0
    }
  end

  defp extract_unique(keep, toss) do
    for {k1, v1} <- keep do
      if Map.has_key?(toss, k1) and Map.get(toss, k1) === v1 do
        {:same, nil}
      else
        {:different, {k1, v1}}
      end
    end
    |> Enum.filter(fn(x) -> elem(x, 0) == :different end)
    |> Enum.map(fn(x) -> elem(x, 1) end)
  end
end
