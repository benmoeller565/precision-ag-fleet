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
  def handle_event("random_task", _, socket) do
    task =
      %FarmFleetLive.Task{
        id: System.unique_integer([:positive]),
        field_id: 1,
        type: Enum.random([:plow, :spray, :survey]),
        location: {
          Enum.random(1..20),
          Enum.random(1..20)
        }
      }

    FarmFleetLive.Dispatcher.assign_task(task)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">

      <h1 class="text-4xl font-bold mb-2">
        Precision Agriculture Fleet Simulation
      </h1>

      <p class="mb-6">
        CSC 461 Final Project
      </p>

      <div class="mb-6">
        <button
          phx-click="random_task"
          class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded"
        >
          Assign Random Task
        </button>
      </div>

      <div class="grid grid-cols-4 gap-4 mb-8">

        <div class="bg-blue-700 text-white p-4 rounded">
          <div>Total Vehicles</div>
          <div class="text-3xl font-bold">
            <%= length(@vehicles) %>
          </div>
        </div>

        <div class="bg-green-700 text-white p-4 rounded">
          <div>Working</div>
          <div class="text-3xl font-bold">
            <%= Enum.count(@vehicles, &(&1.status == :working)) %>
          </div>
        </div>

        <div class="bg-yellow-600 text-white p-4 rounded">
          <div>Idle</div>
          <div class="text-3xl font-bold">
            <%= Enum.count(@vehicles, &(&1.status == :idle)) %>
          </div>
        </div>

        <div class="bg-red-700 text-white p-4 rounded">
          <div>Low Battery</div>
          <div class="text-3xl font-bold">
            <%= Enum.count(@vehicles, &(&1.battery < 20)) %>
          </div>
        </div>

      </div>

      <table class="table-auto border-collapse border border-gray-600 w-full">

        <thead>
          <tr class="bg-gray-800 text-white">
            <th class="border p-3">ID</th>
            <th class="border p-3">Type</th>
            <th class="border p-3">Battery</th>
            <th class="border p-3">Status</th>
            <th class="border p-3">Position</th>
            <th class="border p-3">Task</th>
            <th class="border p-3">Capabilities</th>
            <th class="border p-3">Actions</th>
          </tr>
        </thead>

        <tbody>
          <%= for vehicle <- @vehicles do %>

            <tr>

              <td class="border p-3">
                <%= vehicle.id %>
              </td>

              <td class="border p-3">
                <%= vehicle.type %>
              </td>

              <td class="border p-3">

                <%= if vehicle.battery < 20 do %>
                  <span class="text-red-500 font-bold">
                    <%= vehicle.battery %>
                  </span>
                <% else %>
                  <%= vehicle.battery %>
                <% end %>

              </td>

              <td class="border p-3">

                <%= case vehicle.status do %>

                  <% :working -> %>
                    <span class="text-yellow-400 font-bold">
                      WORKING
                    </span>

                  <% :idle -> %>
                    <span class="text-green-400 font-bold">
                      IDLE
                    </span>

                  <% _ -> %>
                    <%= vehicle.status %>

                <% end %>

              </td>

              <td class="border p-3">
                <%= inspect(vehicle.position) %>
              </td>

              <td class="border p-3">

                <%= if vehicle.current_task do %>
                  <%= vehicle.current_task.type %>
                <% else %>
                  none
                <% end %>

              </td>

              <td class="border p-3">

                <%= vehicle.capabilities
                |> Enum.map(&to_string/1)
                |> Enum.join(", ") %>

              </td>

              <td class="border p-3">

                <button
                  phx-click="crash"
                  phx-value-id={vehicle.id}
                  class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded"
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
