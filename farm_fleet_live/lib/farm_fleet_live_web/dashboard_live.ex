defmodule FarmFleetLiveWeb.DashboardLive do
  use FarmFleetLiveWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :refresh)
    end

    vehicles =
      FarmFleetLive.VehicleSupervisor.get_vehicle_states()

    {:ok, assign(socket, vehicles: vehicles)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    vehicles =
      FarmFleetLive.VehicleSupervisor.get_vehicle_states()

    {:noreply, assign(socket, vehicles: vehicles)}
  end

  @impl true
  def handle_event("crash", %{"id" => id}, socket) do
    vehicle =
      FarmFleetLive.VehicleSupervisor.get_vehicles()
      |> Enum.find(fn {_child_id, pid, _type, _modules} ->
        state = FarmFleetLive.Vehicle.get_state(pid)
        state.id == String.to_integer(id)
      end)

    case vehicle do
      nil ->
        {:noreply, socket}

      {_child_id, pid, _type, _modules} ->
        FarmFleetLive.Vehicle.crash(pid)
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold mb-6">
        Fleet Dashboard
      </h1>

      <table class="table-auto border-collapse border border-gray-500 w-full">
        <thead>
          <tr class="bg-gray-700">
            <th class="border px-4 py-2">ID</th>
            <th class="border px-4 py-2">Type</th>
            <th class="border px-4 py-2">Battery</th>
            <th class="border px-4 py-2">Status</th>
            <th class="border px-4 py-2">Position</th>
            <th class="border px-4 py-2">Task</th>
            <th class="border px-4 py-2">Capabilities</th>
            <th class="border px-4 py-2">Actions</th>
          </tr>
        </thead>

        <tbody>
          <%= for vehicle <- @vehicles do %>
            <tr>
              <td class="border px-4 py-2"><%= vehicle.id %></td>
              <td class="border px-4 py-2"><%= vehicle.type %></td>
              <td class="border px-4 py-2"><%= vehicle.battery %></td>
              <td class="border px-4 py-2"><%= vehicle.status %></td>

              <td class="border px-4 py-2">
                <%= inspect(vehicle.position) %>
              </td>

              <td class="border px-4 py-2">
                <%= if vehicle.current_task do %>
                  <%= inspect(vehicle.current_task) %>
                <% else %>
                  none
                <% end %>
              </td>

              <td class="border px-4 py-2">
                <%= vehicle.capabilities
                    |> Enum.map(&to_string/1)
                    |> Enum.join(", ") %>
              </td>

              <td class="border px-4 py-2">
                <button
                  class="bg-red-600 text-white px-3 py-1 rounded"
                  phx-click="crash"
                  phx-value-id={vehicle.id}
                >
                  Crash
                </button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
