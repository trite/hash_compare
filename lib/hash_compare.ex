defmodule HashCompare do
  @moduledoc """
  Documentation for `HashCompare`.
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

  # Originally planned to use these as function guards
  # but that was overkill for this use case
  # defguard is_valid_key(key) when is_binary(key)
  # defguard is_valid_value(val) when
  #   is_binary(val) or
  #   is_boolean(val) or
  #   is_float(val) or
  #   is_integer(val) or
  #   is_list(val) or
  #   is_map(val)
  def is_valid_key(key) do
    is_binary(key)
  end

  def is_valid_value(val) do
    is_binary(val) or
    is_boolean(val) or
    is_float(val) or
    is_integer(val) or
    is_list(val) or
    is_map(val)
  end

  @doc """
  Hello world.

  ## Examples

      iex> HashCompare.hello()
      :world

  """
  def hello do
    :world
  end

  def add_or_update_foo(m) do
    Map.put(m, "foo", "bar")
  end

  def extract_unique(hash1, hash2) do
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

  @spec validate_map(any) :: boolean()
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
