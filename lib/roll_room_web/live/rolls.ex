defmodule RollRoomWeb.RollsLive do
  use Phoenix.LiveView

  alias RollRoom.Rolling

  def render(assigns) do
    ~L"""
    <div class="whole-thing">
      <p> Your time to roll! </p>
      <ul>
        <%= for result <- @results do %>
          <li><b><%= result.result %></b>: <%= Rolling.dicerolls_to_string(result) %></li>
        <% end %>
      </ul>

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

  defp new_roll_state() do
    %{rollmap: %{20 => 0, 12 => 0, 10 => 0, 8 => 0, 6 => 0, 4 => 0}, bonus: 0, advantage: false, disadvantage: false}
  end

  def mount(_params, _session, socket) do
    Rolling.subscribe()
    rolls = RollRoom.Rolling.list_results()
    {:ok, assign(socket, Map.merge(%{results: rolls},  new_roll_state())) }
  end

  def handle_event("incdie", %{"side" => die_side}, socket) do
    new_rollmap = Map.update!(socket.assigns.rollmap, String.to_integer(die_side), &(&1+1))
    {:noreply, assign(socket, :rollmap, new_rollmap)}
  end

  def handle_event("roll", _, socket) do
    Rolling.create_result(socket.assigns.rollmap, socket.assigns.bonus)
    {:noreply, assign(socket, new_roll_state())}
  end

  def handle_event("bonus", %{"action" => "increase"}, socket) do
    socket = update(socket, :bonus, &(&1+1))
    {:noreply, socket}
  end
  def handle_event("bonus", %{"action" => "decrease"}, socket) do
    socket = update(socket, :bonus, &(&1-1))
    {:noreply, socket}
  end

  def handle_info({:new_result, result}, socket) do
    socket = update(socket, :results, fn results -> [result | results] end)

    {:noreply, socket}
  end

end
