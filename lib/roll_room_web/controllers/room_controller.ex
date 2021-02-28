defmodule RollRoomWeb.RoomController do
  use RollRoomWeb, :controller

  alias RollRoom.Rooms
  alias RollRoom.Rooms.Room

  def index(conn, _params) do
    changeset = Rooms.change_room(%Room{})
    render(conn, "join.html", changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Rooms.change_room(%Room{})
    render(conn, "new.html", changeset: changeset)
  end

  def join(conn, %{"room_name" => name}) do
    {:ok, room} = Rooms.upsert_room(name)
    conn |> redirect(to: "/rooms/#{room.slug}")
  end

  def delete(conn, %{"id" => id}) do
    room = Rooms.get_room!(id)
    {:ok, _room} = Rooms.delete_room(room)

    conn
    |> put_flash(:info, "Room deleted successfully.")
    |> redirect(to: Routes.room_path(conn, :index))
  end
end
