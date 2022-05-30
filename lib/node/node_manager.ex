defmodule NodeManager do
  defstruct node_type: 0

  use GenServer
  use Common

  @loop_interval 1000

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init([node_type]) do
    Process.send_after(self(), :loop, @loop_interval)
    Logger.debug("start node manager, node type :  #{node_type}")
    {:ok, %NodeManager{node_type: node_type}}
  end

  @impl true
  def handle_info(:loop, state) do
    Process.send_after(self(), :loop, @loop_interval)
    state = doloop(state)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warning("unhandled info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.warning("unhandled cast: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_call(msg, _from, state) do
    Logger.warning("unhandled call: #{inspect(msg)}")
    {:reply, {:error, :unhandle_msg}, state}
  end

  defp doloop(state) do
    state
  end
end
