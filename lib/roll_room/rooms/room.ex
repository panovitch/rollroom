defmodule RollRoom.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> slugify_name()
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end

  defp slugify_name(changeset) do
    case fetch_change(changeset, :name) do
      {:ok, new_name} -> put_change(changeset, :slug, slugify(new_name))
      :error -> changeset
    end
  end
end
