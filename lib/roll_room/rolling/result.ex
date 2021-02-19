defmodule RollRoom.Rolling.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roll_results" do
    field :advantage, :boolean, null: false, default: false
    field :disadvantage, :boolean, null: false, default: false
    field :bonus, :integer, default: 0, null: false
    field :dicerolls, {:array, :integer}, null: false
    field :secondary_dicerolls, {:array, :integer}
    field :result , :integer, null: false


    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:dicerolls, :bonus, :advantage, :result])
    |> validate_required([:dicerolls, :bonus, :advantage, :result])
  end
end