defmodule FarmFleet.VehicleTest do
  use ExUnit.Case

  test "vehicle starts idle" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray]
      )

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.status == :idle
  end

  test "vehicle accepts a task" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray]
      )

    task = %FarmFleet.Task{
      id: 1,
      type: :spray,
      location: {1, 1}
    }

    FarmFleet.Vehicle.assign_task(vehicle, task)

    :timer.sleep(100)

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.status == :working
  end

  test "battery decreases after task completion" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray]
      )

    task = %FarmFleet.Task{
      id: 1,
      type: :spray,
      location: {0, 0}
    }

    FarmFleet.Vehicle.assign_task(vehicle, task)

    :timer.sleep(7000)

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.battery == 90
  end

  test "vehicle can charge" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        battery: 50
      )

    FarmFleet.Vehicle.charge(vehicle, 25)

    :timer.sleep(100)

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.battery == 75
  end

  test "capabilities are stored correctly" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray]
      )

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert :spray in state.capabilities
  end

  test "vehicle moves toward target" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray],
        position: {0, 0}
      )

    task = %FarmFleet.Task{
      id: 1,
      type: :spray,
      location: {3, 3}
    }

    FarmFleet.Vehicle.assign_task(vehicle, task)

    :timer.sleep(2000)

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.position != {0, 0}
  end

  test "task eventually completes" do
    {:ok, vehicle} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        capabilities: [:spray]
      )

    task = %FarmFleet.Task{
      id: 1,
      type: :spray,
      location: {0, 0}
    }

    FarmFleet.Vehicle.assign_task(vehicle, task)

    :timer.sleep(7000)

    state = FarmFleet.Vehicle.get_state(vehicle)

    assert state.status == :idle
    assert state.current_task == nil
  end
end
