defmodule RollRoom.Rolling do
  alias RollRoom.Rolling.Result
  alias RollRoom.Repo
  import Ecto.Query

  def roll_die(side, 1) do
    result = Enum.random(1..side)
    {result, [result]}
  end
  def roll_die(side, amount) do
    result = Enum.random(1..side)
    {next_result, next_values} = roll_die(side, amount - 1)
    {result + next_result, [result] ++ next_values}
  end

  def empty?(rollmap) do
    Enum.empty?(rollmap |> Enum.filter(fn {_, value} -> value != 0 end))
  end

  def cast(rollmap) do
    rollmap
    |> Enum.filter(fn {_, value} -> value != 0 end)
    |> Enum.map(fn {key, value} -> roll_die(key, value) end)
    |> Enum.reduce({0, []}, fn {result, values}, {prev_result, prev_values} -> {prev_result + result, prev_values ++ values} end)
  end

  def double_cast(rollmap, advantage) do
    {first_result, first_values} = cast(rollmap)
    {second_result, second_values} = cast(rollmap)


    cond do
      advantage and first_result >= second_result ->
        {first_result, first_values, second_values}
      advantage and first_result < second_result ->
        {second_result, second_values, first_values}
      not advantage and first_result >= second_result ->
        {second_result, second_values, first_values}
      not advantage and first_result < second_result ->
        {first_result, first_values, second_values}
    end
  end


  def create_result(%{rollmap: rollmap, bonus: bonus, room: room, username: username, advantage: false, disadvantage: false}) do
    {result, values} = cast(rollmap)
    save_result(room, %{result: result + bonus, username: username, dicerolls: values, bonus: bonus})
  end
  def create_result(%{rollmap: rollmap, bonus: bonus, room: room, username: username, advantage: advantage, disadvantage: disadvantage}) do
    adv = advantage and not disadvantage
    {result, winning_dicerolls, loosing_dicerolls} = double_cast(rollmap, adv)
    save_result(room, %{result: result + bonus, username: username, dicerolls: winning_dicerolls, secondary_dicerolls: loosing_dicerolls, bonus: bonus, advantage: advantage, disadvantage: disadvantage})
  end


  def save_result(%RollRoom.Rooms.Room{} = room, attrs) do
    %Result{}
    |> Result.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:room, room)
    |> Repo.insert()
    |> notify(room)
  end

  defp notify({:ok, result}, %RollRoom.Rooms.Room{} = room) do
    Phoenix.PubSub.broadcast!(RollRoom.PubSub, "results_#{room.id}", {:new_result,  result})
    {:ok, result}
  end
  defp notify({:error, error}, _) do
    IO.inspect(error)
  end

  def subscribe(%RollRoom.Rooms.Room{} = room) do
    Phoenix.PubSub.subscribe(RollRoom.PubSub, "results_#{room.id}")
  end

  def list_results(room) do
    Repo.all(
      from res in Result,
        where: [room_id: ^room.id],
        order_by: [desc: res.inserted_at],
        limit: 200
    )
  end

  defp die_to_string(side, 1) do
    "d#{side}"
  end
  defp die_to_string(side, amount) do
    "#{amount}d#{side}"
  end
  def roll_to_string(rollmap, bonus) do
    rollstring = rollmap
    |> Enum.filter(fn {_, value} -> value != 0 end)
    |> Enum.map(fn {side, amount} -> die_to_string(side, amount) end)
    |> Enum.join(" + ")

    "#{rollstring} #{bonus_to_string(bonus)}"
  end

  def result_to_string(result) when result.advantage == true do
    dicerolls_text = dicerolls_to_string(result.dicerolls)
    loosing_diceroll_text = dicerolls_to_string(result.secondary_dicerolls)
    "advantage: #{dicerolls_text} over #{loosing_diceroll_text} #{bonus_to_string(result.bonus)}"
  end
  def result_to_string(result) when result.disadvantage do
    dicerolls_text = dicerolls_to_string(result.dicerolls)
    loosing_diceroll_text = dicerolls_to_string(result.secondary_dicerolls)
    "disadvantage: #{dicerolls_text} over #{loosing_diceroll_text} #{bonus_to_string(result.bonus)}"
  end
  def result_to_string(result) do
    dicerolls_text = dicerolls_to_string(result.dicerolls)
    "#{dicerolls_text} #{bonus_to_string(result.bonus)}"
  end

  def dicerolls_to_string(dicerolls) do
    dicerolls |> Enum.map(&("(#{&1})")) |> Enum.join(" + ")
  end

  defp bonus_to_string(bonus) do
    cond do
      bonus == 0 -> ""
      bonus > 0 -> "+ #{abs(bonus)}"
      bonus < 0 -> "- #{abs(bonus)}"
      true -> ""
    end
  end

end
