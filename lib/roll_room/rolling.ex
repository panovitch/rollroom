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

  def cast(rollmap) do
    rollmap
    |> Enum.filter(fn {_, value} -> value != 0 end)
    |> Enum.map(fn {key, value} -> roll_die(key, value) end)
    |> Enum.reduce({0, []}, fn {result, values}, {prev_result, prev_values} -> {prev_result + result, prev_values ++ values} end)
  end

  def create_result(rollmap) do
    {result, values} = cast(rollmap)
    save_result(%{result: result, dicerolls: values})
  end
  def create_result(rollmap, bonus) do
    {result, values} = cast(rollmap)
    save_result(%{result: result + bonus, dicerolls: values, bonus: bonus})
  end

  def save_result(attrs) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
    |> notify()
  end

  defp notify({:ok, result}) do
    Phoenix.PubSub.broadcast!(RollRoom.PubSub, "results", {:new_result,  result})
    {:ok, result}
  end
  defp notify({:error, error}) do
    IO.inspect(error)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(RollRoom.PubSub, "results")
  end

  def list_results do
    Repo.all(
      from res in Result,
        order_by: [desc: res.inserted_at],
        limit: 200
    )
  end
end
