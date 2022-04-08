defmodule HashCompareTest do
  use ExUnit.Case

  # It seems a bit redundant to do the same tests below that are also done in the doctests.
  # But I'm not sure what the preferred practices around this are just yet, keeping both for now.
  doctest HashCompare

  test "identical hashes are equal" do
    assert %{
      "are_equal" => true,
      "left_only" => [],
      "right_only" => []
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "bar"})
  end

  test "similar keys but different values show up in both of result" do
    assert %{
      "are_equal" => false,
      "left_only" => [{"foo", "bar"}],
      "right_only" => [{"foo", "tacos"}]
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "tacos"})
  end

  test "only extracts key/value pairs that do not have an exact match" do
    assert %{
        "are_equal" => false,
        "left_only" => [{"almost", "thesame"}, {"foo", "bar"}],
        "right_only" => [{"almost", "butnotquite"}]
      } == HashCompare.compare(
        %{"5" => "42", "almost" => "thesame", "foo" => "bar" },
        %{"5" => "42", "almost" => "butnotquite"})
  end

  test "identical maps with child lists/maps compare as same" do
    complex = %{
      5 => "42",
      :something => [ "foo", "bar", "baz" ],
      "food_today" => %{
        "breakfast" => "eggs",
        "lunch" => "tacos",
        "dinner" => "stir fry"
      }
    }

    assert %{
      "are_equal" => true,
      "left_only" => [],
      "right_only" => []
      } == HashCompare.compare(complex, complex)
  end

  test "different maps with child lists/maps only extracts non-matched pairs" do
    left = %{
      5 => "42",
      "food_today" => %{
        "breakfast" => "eggs",
        "lunch" => "tacos",
        "dinner" => "stir fry"
      }
    }
    right = %{
      5 => "42",
      :something => [ "foo", "bar", "baz" ]
    }

    assert %{
      "are_equal" => false,
      "left_only" => [
        {"food_today",
          %{
            "breakfast" => "eggs",
            "dinner" => "stir fry",
            "lunch" => "tacos"
          }}
      ],
      "right_only" => [something: ["foo", "bar", "baz"]]
    } == HashCompare.compare(left, right)
  end
end
