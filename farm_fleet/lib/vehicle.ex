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

  def charge(pid, amount) do
    GenServer.cast(pid, {:charge, amount})
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
      capabilities: Keyword.get(opts, :capabilities, []),
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
    Process.send_after(self(), :move, 1000)

    new_state =
      state
      |> Map.put(:current_task, task)
      |> Map.put(:status, :working)
      |> Map.put(:target_location, task.location)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:charge, amount}, state) do
    new_battery =
      min(state.battery + amount, 100)

    {:noreply, %{state | battery: new_battery}}
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
  def handle_info(:move, state) do
    {x, y} = state.position
    {tx, ty} = state.target_location

    new_x =
      cond do
        x < tx -> x + 1
        x > tx -> x - 1
        true -> x
      end

    new_y =
      cond do
        y < ty -> y + 1
        y > ty -> y - 1
        true -> y
      end

    new_position = {new_x, new_y}

    if new_position == state.target_location do
      Process.send_after(self(), :finish_task, 1000)
    else
      Process.send_after(self(), :move, 1000)
    end

    {:noreply, %{state | position: new_position}}
  end

  @impl true
  def handle_info(:finish_task, state) do
    new_battery =
      max(state.battery - 10, 0)

    new_state =
      state
      |> Map.put(:status, :idle)
      |> Map.put(:current_task, nil)
      |> Map.put(:battery, new_battery)

    {:noreply, new_state}
  end
end
