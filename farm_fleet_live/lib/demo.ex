defmodule FarmFleetLive.DemoRunner do
  alias FarmFleetLive.VehicleSupervisor
  alias FarmFleetLive.Dispatcher
  alias FarmFleetLive.Task

  def start_demo do
    spawn(fn ->
      run_demo()
    end)
  end

  defp run_demo do
    # Wait for dashboard startup
    :timer.sleep(2_000)

    # Create fleet
    VehicleSupervisor.start_vehicle(
      id: 1,
      type: :tractor,
      capabilities: [:plow, :seed],
      position: {0, 0}
    )

    :timer.sleep(2_000)

    VehicleSupervisor.start_vehicle(
      id: 2,
      type: :sprayer,
      capabilities: [:spray],
      position: {10, 5}
    )

    :timer.sleep(2_000)

    VehicleSupervisor.start_vehicle(
      id: 3,
      type: :drone,
      capabilities: [:survey, :spray],
      position: {20, 10}
    )

    :timer.sleep(2_000)

    VehicleSupervisor.start_vehicle(
      id: 4,
      type: :harvester,
      capabilities: [:harvest],
      position: {5, 15}
    )

    :timer.sleep(2_000)

    VehicleSupervisor.start_vehicle(
      id: 5,
      type: :drone,
      capabilities: [:survey],
      position: {30, 12}
    )

    # Start work
    :timer.sleep(3_000)

    Dispatcher.assign_task(%Task{
      id: 1,
      field_id: 1,
      type: :plow,
      location: {6, 6}
    })

    :timer.sleep(4_000)

    Dispatcher.assign_task(%Task{
      id: 2,
      field_id: 2,
      type: :spray,
      location: {15, 10}
    })

    :timer.sleep(4_000)

    Dispatcher.assign_task(%Task{
      id: 3,
      field_id: 3,
      type: :survey,
      location: {25, 10}
    })

    # Demonstrate crash recovery
    :timer.sleep(8_000)

    vehicles =
      VehicleSupervisor.get_vehicles()

    case vehicles do
      [{_, pid, _, _} | _] ->
        FarmFleetLive.Vehicle.crash(pid)

      _ ->
        :ok
    end

    # Demonstrate more assignments
    :timer.sleep(8_000)

    Dispatcher.assign_task(%Task{
      id: 4,
      field_id: 4,
      type: :spray,
      location: {20, 20}
    })
  end
end
