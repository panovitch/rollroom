defmodule RollRoom.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :slug, :string

      timestamps()
    end

    alter table(:roll_results) do
      add :room_id, references(:rooms, on_delete: :nothing)
    end
  end
end
