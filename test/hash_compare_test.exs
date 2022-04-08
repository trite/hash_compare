defmodule HashCompareTest do
  use ExUnit.Case
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

  test "identical hashes are n equal" do
    assert %{
      "are_equal" => false,
      "left_only" => [{"foo", "bar"}],
      "right_only" => [{"foo", "tacos"}]
    } == HashCompare.compare(
      %{"foo" => "bar"},
      %{"foo" => "tacos"})
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
