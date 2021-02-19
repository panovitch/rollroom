defmodule RollRoomWeb.RollsLive do
  use Phoenix.LiveView

  alias RollRoom.Rolling

  def render(assigns) do
    ~L"""
    <div class="whole-thing">
      <p> Your time to roll! </p>
      <ul>
        <%= for %{:result => result} <- @results do %>
          <li> <%= result %> </li>
        <% end %>
      </ul>

      <div class="controls">
        <p><%= Map.get(@rollmap, 20) %></p>
        <button phx-click="incd20" class="plus">+ d20</button>
        <button phx-click="decd20" class="minus">- d20</button>
        <button phx-click="roll" class="minus">Roll!</button>
      </div>
    </div>
    """
  end

  defp new_rollmap() do
    %{20 => 0, 12 => 0, 10 => 0, 8 => 0, 6 => 0, 4 => 0}
  end

  def mount(_params, _session, socket) do
    Rolling.subscribe()
    rolls = RollRoom.Rolling.list_results()
    {:ok, assign(socket, results: rolls, rollmap: new_rollmap())}
  end

  def handle_event("incd20", _, socket) do
    new_rollmap = Map.update!(socket.assigns.rollmap, 20, &(&1+1))
    {:noreply, assign(socket, :rollmap, new_rollmap)}
  end

  # def rollmap_from_assigns(assigns) do

  #   for dice_side <- [20, 12, 10, 8, 6, 4], into: %{} do
  #     value = Map.get(assigns, String.to_atom("d_" <> Integer.to_string(dice_side)), 0)
  #     {dice_side, value}
  #   end
  # end

  def handle_event("roll", _, socket) do
    Rolling.create_result(socket.assigns.rollmap)
    {:noreply, assign(socket, rollmap: new_rollmap())}
  end

  def handle_info({:new_result, result}, socket) do
    IO.puts("asd")
    socket = update(socket, :results, fn results -> [result | results] end)

    {:noreply, socket}
  end

  def a(results, result) do
    IO.puts results
    IO.puts result
  end

end
