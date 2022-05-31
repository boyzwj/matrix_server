defmodule DBContact.NodeManager do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok,
     %{
       nodes: %{}
     }}
  end

  @impl true
  def handle_call({:register, node}, _from, state) do
    new_state = add_node(state, node)
    Node.monitor(node, true)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:db_list, _from, state) do
    {:reply, Map.keys(state.nodes), state}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    Logger.debug("Node connected: #{node}")
    new_state = %{state | nodes: %{state.nodes | node => :online}}
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:nodedown, node}, state) do
    Logger.critical("Node disconnected: #{node}")
    new_state = %{state | nodes: %{state.nodes | node => :offline}}
    {:noreply, new_state}
  end

  defp add_node(state = %{nodes: nodes}, node) do
    %{state | nodes: Map.put(nodes, node, :online)}
  end
end
