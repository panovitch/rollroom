defmodule RollRoomWeb.RollsLive do
  use Phoenix.LiveView

  alias RollRoom.Rolling

  @defaults %{rollmap: %{20 => 0, 12 => 0, 10 => 0, 8 => 0, 6 => 0, 4 => 0}, bonus: 0, advantage: false, disadvantage: false}

  def render(assigns) do
    ~L"""
    <%= if @show_user_modal do %>
    <!-- Modal Background -->
      <div class="phx-modal">
        <div class="phx-modal-content">
          <div class="modal-title">
            Who are you?
          </div>
          <form phx-submit="save_username">
            <input type="text" name="u" placeholder="Enter a name"/>
            <button type="submit">Ok!</button>
          </form>
        </div>
      </div>
    <% end %>

    <div class="whole-thing">
      <p> Your time to roll! </p>
      <div class="rollarea">
        <%= for result <- @results do %>
        <p>🎲 <b><%= result.username %></b> rolled <b><%= result.result %></b>: <%= Rolling.dicerolls_to_string(result) %></p>
        <% end %>
      </div>

      <div class="controls">
        <div class="dice">
          <%= for { die_side, die_amount } <- @rollmap do %>
            <button phx-click="incdie" phx-value-side=<%= die_side %> phxclass="plus"><%= die_side %> (<%= die_amount %>)</button>
          <% end %>
        </div>
        <div>
          <p> <%= @bonus %> </p>
          <button phx-click="bonus" phxclass="plus" phx-value-action="increase">+</button>
          <button phx-click="bonus" phxclass="minus" phx-value-action="decrease">-</button>
        </div>
        <button phx-click="roll" phxclass="plus"> roll! </button>
      </div>
    </div>
    """
  end

  def mount(%{"slug" => room_slug}, _session, socket) do
    room = RollRoom.Rooms.get_room_by_slug!(room_slug)
    Rolling.subscribe(room)
    rolls = RollRoom.Rolling.list_results(room)
    {:ok, assign(socket, Map.merge(%{room: room, results: rolls, show_user_modal: true, current_username: nil}, @defaults)) }
  end

  def handle_event("incdie", %{"side" => die_side}, socket) do
    new_rollmap = Map.update!(socket.assigns.rollmap, String.to_integer(die_side), &(&1+1))
    {:noreply, assign(socket, :rollmap, new_rollmap)}
  end

  def handle_event("roll", _, socket) do
    Rolling.create_result(socket.assigns.room, socket.assigns.current_username, socket.assigns.rollmap, socket.assigns.bonus)
    {:noreply, assign(socket, @defaults)}
  end

  def handle_event("bonus", %{"action" => "increase"}, socket) do
    socket = update(socket, :bonus, &(&1+1))
    {:noreply, socket}
  end
  def handle_event("bonus", %{"action" => "decrease"}, socket) do
    socket = update(socket, :bonus, &(&1-1))
    {:noreply, socket}
  end

  def handle_event("save_username", %{"u" => username}, socket) do
    {:noreply, assign(socket, %{current_username: username, show_user_modal: false})}
  end

  def handle_info({:new_result, result}, socket) do
    socket = update(socket, :results, fn results -> [result | results] end)

    {:noreply, socket}
  end

end
