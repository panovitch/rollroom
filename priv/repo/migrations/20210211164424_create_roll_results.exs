defmodule RollRoom.Repo.Migrations.CreateRollResults do
  use Ecto.Migration

  def change do
    create table(:roll_results) do
      add :dicerolls, {:array, :integer}, null: false
      add :secondary_dicerolls, {:array, :integer}
      add :bonus, :integer, default: 0, null: false
      add :advantage, :boolean
      add :disadvantage, :boolean
      add :result, :integer, null: false

      timestamps()
    end

  end
end
