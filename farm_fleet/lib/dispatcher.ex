defmodule FarmFleet.Dispatcher do
  defp distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp can_perform?(state, task) do
    task.type in state.capabilities
  end

  def assign_task(task) do
    available_vehicle =
      FarmFleet.VehicleSupervisor.get_vehicles()
      |> Enum.map(fn {_id, pid, _type, _modules} ->
        {pid, FarmFleet.Vehicle.get_state(pid)}
      end)
      |> Enum.filter(fn {_pid, state} ->
        state.status == :idle &&
        state.battery > 20 &&
        can_perform?(state, task)
      end)
      |> Enum.min_by(
        fn {_pid, state} ->
          distance(state.position, task.location)
        end,
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
