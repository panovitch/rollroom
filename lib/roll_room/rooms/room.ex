defmodule RollRoom.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :slug, :string
    field :room_id, :integer

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
