defmodule RollRoomWeb.RollsLive do
  use Phoenix.LiveView

  alias RollRoom.Rolling

  @defaults %{
    rollmap: %{20 => 0, 12 => 0, 10 => 0, 8 => 0, 6 => 0, 4 => 0},
    bonus: 0,
    advantage: false,
    disadvantage: false,
    previous_states: []
  }

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
        <p>🎲 <b><%= result.username %></b> rolled <b><%= result.result %></b>: <%= Rolling.result_to_string(result) %></p>
        <% end %>
      </div>

      <div class="controls">
        <div class="dice">
          <%= for { die_side, die_amount } <- @rollmap do %>
            d<%= die_side %>: <%= die_amount %>
            <button phx-click="incdie" phx-value-side=<%= die_side %> phxclass="plus">+</button>
            <button phx-click="decdie" phx-value-side=<%= die_side %> phxclass="minus">-</button>
          <% end %>
        </div>
        <div>
          <p> <%= @bonus %> </p>
          <button phx-click="bonus" phxclass="plus" phx-value-action="increase">+</button>
          <button phx-click="bonus" phxclass="minus" phx-value-action="decrease">-</button>
        </div>
        <div>
            <button phx-click="advantage" class=<%= if @advantage, do: "enabled", else: "disabled" %>>
            adv</button>
            <button phx-click="disadvantage" class=<%= if @disadvantage, do: "enabled", else: "disabled" %>>
            disadv</button>

        </div>
        <button phx-click="roll" phxclass="plus"> roll! </button>
      </div>
      <div class="rerolls">
        <%= for {%{rollmap: rollmap, bonus: bonus}, index} <- Enum.with_index(@previous_states) do %>
          <button phx-click="reroll" phx-value-roll_index=<%= index %> phxclass="plus"><%= Rolling.roll_to_string(rollmap, bonus) %></button>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"slug" => room_slug}, _session, socket) do
    room = RollRoom.Rooms.get_room_by_slug!(room_slug)
    Rolling.subscribe(room)
    rolls = RollRoom.Rolling.list_results(room)
    {:ok, assign(socket, Map.merge(%{room: room, results: rolls, show_user_modal: true, username: nil}, @defaults)) }
  end

  defp create_result_and_refresh(socket, state) do
    Rolling.create_result(state)

    Map.put(
      @defaults,
      :previous_states,
      [ Map.delete(socket.assigns, :results) | socket.assigns.previous_states]
    )
  end

  def handle_event("incdie", %{"side" => die_side}, socket) do
    new_rollmap = Map.update!(socket.assigns.rollmap, String.to_integer(die_side), &(&1+1))
    {:noreply, assign(socket, :rollmap, new_rollmap)}
  end
  def handle_event("decdie", %{"side" => die_side}, socket) do
    IO.puts Map.get(socket.assigns.rollmap, String.to_integer(die_side))
    if Map.get(socket.assigns.rollmap, String.to_integer(die_side)) > 0 do
      new_rollmap = Map.update!(socket.assigns.rollmap, String.to_integer(die_side), &(&1-1))
      {:noreply, assign(socket, :rollmap, new_rollmap)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reroll",  %{"roll_index" => index}, socket) do
    state = Enum.at(socket.assigns.previous_states, String.to_integer(index))
    new_state = create_result_and_refresh(socket, state)
    {:noreply, assign(socket, new_state)}
  end

  def handle_event("roll", _, socket) do
    new_state = create_result_and_refresh(socket, socket.assigns)
    {:noreply, assign(socket, new_state)}
  end

  def handle_event("bonus", %{"action" => "increase"}, socket) do
    socket = update(socket, :bonus, &(&1+1))
    {:noreply, socket}
  end
  def handle_event("bonus", %{"action" => "decrease"}, socket) do
    socket = update(socket, :bonus, &(&1-1))
    {:noreply, socket}
  end


  def handle_event("advantage", _, socket) do
    socket = assign(socket, :advantage, not socket.assigns.advantage)
    socket = assign(socket, :disadvantage, not socket.assigns.advantage and socket.assigns.disadvantage)
    {:noreply, socket}
  end
  def handle_event("disadvantage", _, socket) do
    socket = assign(socket, :disadvantage, not socket.assigns.disadvantage)
    socket = assign(socket, :advantage, not socket.assigns.disadvantage and socket.assigns.advantage)
    {:noreply, socket}
  end

  def handle_event("save_username", %{"u" => username}, socket) do
    {:noreply, assign(socket, %{username: username, show_user_modal: false})}
  end

  def handle_info({:new_result, result}, socket) do
    socket = update(socket, :results, fn results -> [result | results] end)

    {:noreply, socket}
  end


end
