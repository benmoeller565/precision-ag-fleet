defmodule FarmFleet.DemoTest do
  use ExUnit.Case

  test "fleet simulation demo" do
    IO.puts("\n=== Vehicle Creation ===")

    {:ok, tractor} =
      FarmFleet.Vehicle.start_link(
        id: 1,
        type: :tractor,
        capabilities: [:plow, :seed],
        position: {0, 0}
      )

    IO.inspect(FarmFleet.Vehicle.get_state(tractor))

    IO.puts("\n=== Task Creation ===")

    task = %FarmFleet.Task{
      id: 1,
      field_id: 1,
      type: :plow,
      location: {3, 3}
    }

    IO.inspect(task)

    IO.puts("\n=== Assigning Task ===")

    FarmFleet.Vehicle.assign_task(tractor, task)

    :timer.sleep(100)

    IO.inspect(FarmFleet.Vehicle.get_state(tractor))

    IO.puts("\n=== Vehicle Moving ===")

    :timer.sleep(3000)

    IO.inspect(FarmFleet.Vehicle.get_state(tractor))

    IO.puts("\n=== Task Completion ===")

    :timer.sleep(5000)

    IO.inspect(FarmFleet.Vehicle.get_state(tractor))

    assert true
  end
end
