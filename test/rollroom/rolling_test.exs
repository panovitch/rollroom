defmodule RollRoom.RollingTest do
  use RollRoom.DataCase, async: true

  alias RollRoom.Rolling

  describe "rolling die" do
    test "rolls the die" do
      {result, values} = Rolling.roll_die(1, 1)

      assert result == 1
      assert values == [1]
    end

    test "roll many dice with one side" do
      {result, values} = Rolling.roll_die(1, 3)

      assert result == 3
      assert values == [1, 1, 1]
    end

    test "roll many dice with different sides" do
      {result, values} = Rolling.cast(%{1 => 2, 2 => 2})

      assert result >= 4
      assert result <= 8
      assert length(values) == 4
    end

    test "roll many dice with different sides ignore 0s" do
      {result, values} = Rolling.cast(%{1 => 2, 2 => 0})

      assert length(values) == 2
    end

    test "get result with a bonus" do
      result = Rolling.create_result(%{1 => 3}, 5)
      assert result.result == 8
      result = Rolling.create_result(%{1 => 3}, -2)
      assert result.result == 1
    end
  end
end
