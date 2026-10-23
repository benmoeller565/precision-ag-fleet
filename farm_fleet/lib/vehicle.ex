defmodule FarmFleet.Vehicle do
  use GenServer

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def assign_task(pid, task) do
    GenServer.cast(pid, {:assign_task, task})
  end

  def update_position(pid, position) do
    GenServer.cast(pid, {:update_position, position})
  end

  def consume_battery(pid, amount) do
    GenServer.cast(pid, {:consume_battery, amount})
  end

  def crash(pid) do
    GenServer.cast(pid, :crash)
  end

  def complete_task(pid) do
    GenServer.cast(pid, :complete_task)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    state = %{
      id: Keyword.get(opts, :id),
      type: Keyword.get(opts, :type, :tractor),
      position: Keyword.get(opts, :position, {0, 0}),
      battery: Keyword.get(opts, :battery, 100),
      status: :idle,
      current_task: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:assign_task, task}, state) do
    Process.send_after(self(), :finish_task, 5_000)

    new_state =
      state
      |> Map.put(:current_task, task)
      |> Map.put(:status, :working)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:update_position, position}, state) do
    {:noreply, %{state | position: position}}
  end

  @impl true
  def handle_cast({:consume_battery, amount}, state) do
    new_battery = max(state.battery - amount, 0)

    {:noreply, %{state | battery: new_battery}}
  end

  @impl true
  def handle_cast(:crash, state) do
    raise "Vehicle #{state.id} simulated crash"
  end

  @impl true
  def handle_cast(:complete_task, state) do
    new_state =
      state
      |> Map.put(:status, :idle)
      |> Map.put(:current_task, nil)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:finish_task, state) do
    new_state =
      state
      |> Map.put(:status, :idle)
      |> Map.put(:current_task, nil)

    {:noreply, new_state}
  end
end
