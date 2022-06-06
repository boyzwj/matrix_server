defmodule DBManager do
  use GenServer
  use Common
  defstruct nodes: %{}

  def get_db_list() do
    GenServer.call(via_tuple(__MODULE__), :get_db_list)
  end

  def register(node) do
    GenServer.call(via_tuple(__MODULE__), {:register, node})
  end

  def ready(node) do
    GenServer.call(via_tuple(__MODULE__), {:ready, node})
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: via_tuple(__MODULE__))
  end

  @impl true
  def init(_args) do
    Logger.debug("db manager started")
    {:ok, %DBManager{}}
  end

  @impl true
  def handle_call(:get_db_list, _from, ~M{nodes} = state) do
    if nodes |> Map.values() |> Enum.any?(&(&1 != :ready)) do
      {:reply, {:error, :prepare}, state}
    else
      reply = nodes |> Map.keys()
      {:reply, {:ok, reply}, state}
    end
  end

  @impl true

  def handle_call({:register, node}, _from, ~M{nodes} = state) do
    nodes = Map.put(nodes, node, :prepare)
    {:reply, :ok, ~M{state|nodes}}
  end

  def handle_call({:ready, node}, _from, ~M{nodes} = state) do
    nodes = Map.put(nodes, node, :ready)
    {:reply, :ok, ~M{state|nodes}}
  end

  def handle_call({:node_off, node}, _from, ~M{nodes} = state) do
    nodes = Map.put(nodes, node, :offline)
    {:reply, :ok, ~M{state|nodes}}
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {Matrix.DBRegistry, name}}
  end
end
