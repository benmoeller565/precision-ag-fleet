defmodule FarmFleet.Dispatcher do
  def assign_task(task) do
    vehicles =
      FarmFleet.VehicleSupervisor.get_vehicles()

    available_vehicle =
      vehicles
      |> Enum.map(fn {_id, pid, _type, _modules} ->
        {pid, FarmFleet.Vehicle.get_state(pid)}
      end)
      |> Enum.filter(fn {_pid, state} ->
        state.status == :idle &&
        state.battery > 20
      end)
      |> Enum.max_by(
        fn {_pid, state} -> state.battery end,
        fn -> nil end
      )

    case available_vehicle do
      nil ->
        {:error, :no_available_vehicle}

      {pid, _state} ->
        FarmFleet.Vehicle.assign_task(pid, task)
        {:ok, pid}
    end
  end
end
