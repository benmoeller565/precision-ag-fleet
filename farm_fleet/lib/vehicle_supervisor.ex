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
end
