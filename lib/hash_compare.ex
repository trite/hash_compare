defmodule HashCompare do
  @moduledoc """
  Documentation for `HashCompare`.

  This module provides a single function, `compare`, which compares two hashes.
  """

  @type valid_key() :: String.t()
  @type valid_value() ::
    String.t()
    | boolean()
    | float()
    | integer()
    | list(valid_value())
    | valid_map()
  @type valid_map() :: %{valid_key() => valid_value()}

  defp is_valid_key(key) do
    is_binary(key)
  end

  defp is_valid_value(val) do
    is_binary(val) or
    is_boolean(val) or
    is_float(val) or
    is_integer(val) or
    is_list(val) or
    is_map(val)
  end

  defp extract_unique(hash1, hash2) do
    for {k1, v1} <- hash1 do
      if Map.has_key?(hash2, k1) and Map.get(hash2, k1) === v1 do
        {:same, nil}
      else
        {:different, {k1, v1}}
      end
    end
    |> Enum.filter(fn(x) -> elem(x, 0) == :different end)
    |> Enum.map(fn(x) -> elem(x, 1) end)
  end


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
        "left_only" => [{"foo", "bar"}],
        "right_only" => [{"foo", "tacos"}]
      }
  """
  # @spec compare(valid_map(), valid_map()) :: %{optional(<<_::64, _::_*8>>) => boolean | list}
  # @spec compare(valid_map(), valid_map()) :: %{ are_equal: boolean(), left_only: list(tuple()), right_only: list(tuple()) }
  def compare(hash1, hash2) do
    if !validate_map(hash1) or !validate_map(hash2) do
      raise "Invalid map"
    end

    hash1_unique = extract_unique(hash1, hash2)
    hash2_unique = extract_unique(hash2, hash1)

    %{
      "left_only" => hash1_unique,
      "right_only" => hash2_unique,
      "are_equal" => Enum.count(hash1_unique) == 0 and Enum.count(hash2_unique) == 0
    }
  end

  # @spec validate_map(any) :: boolean()
  def validate_map(m) do
    for {k, v} <- m do
      if !is_valid_key(k) do
        false
      end
      if !is_valid_value(v) do
        false
      end
    end
    true
  end
end
