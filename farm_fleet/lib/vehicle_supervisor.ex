defmodule FarmFleet.VehicleSupervisor do
  use DynamicSupervisor

  def start_link(arg \\ []) do
    DynamicSupervisor.start_link(__MODULE__, arg,
      name: __MODULE__
    )
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_vehicle(opts) do
    child_spec = {FarmFleet.Vehicle, opts}

    DynamicSupervisor.start_child(
      __MODULE__,
      child_spec
    )
  end

  def get_vehicles do
    DynamicSupervisor.which_children(__MODULE__)
  end

  
  def get_vehicle_states do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {_id, pid, _type, _modules} ->
      {pid, FarmFleet.Vehicle.get_state(pid)}
    end)
  end
end
