defmodule HashCompareTest do
  use ExUnit.Case
  doctest HashCompare

  test "greets the world" do
    assert HashCompare.hello() == :world
  end

  test "adds foo if not present" do
    assert %{"blah" => "blargh", "foo" => "bar"}
      == HashCompare.add_or_update_foo(%{"blah" => "blargh"})
  end

  test "updates foo if present" do
    assert %{"blah" => "blargh", "foo" => "bar"}
      == HashCompare.add_or_update_foo(%{"blah" => "blargh", "foo" => "bash"})
  end

  test "result is unchanged if same" do
    m = %{"blah" => "blargh", "foo" => "bar"}
    assert m == HashCompare.add_or_update_foo(m)
  end

  test "identical hashes are equal" do
    assert %{
      "are_equal" => true,
      "left_only" => [],
      "right_only" => []
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "bar"})
  end

  test "only strings allowed as keys" do
    assert %{
      "are_equal" => false,
      "left_only" => [{5, 42}],
      "right_only" => [{"foo", "bar"}]
    } == HashCompare.compare(
      %{5 => 42},
      %{"foo" => "bar"})
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
end
