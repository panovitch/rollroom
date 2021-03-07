defmodule RollRoom.Repo.Migrations.AddUsername do
  use Ecto.Migration
  def change do

    alter table(:roll_results) do
      add :username, :string
    end
  end
end
