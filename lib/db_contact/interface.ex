defmodule DBContact.Interface do
  use GenServer
  use Common

  @beacon :"beacon_1@127.0.0.1"
  @resource :db_contact
  @requirement []

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    Logger.debug("init args : #{inspect(args)}")
    {:ok, %{server_state: :waiting_node}, 0}
  end

  @impl true
  def handle_info(:timeout, state) do
    send(self(), {:join, @beacon})
    {:noreply, state}
  end

  @impl true
  def handle_info({:join, beacon}, state) do
    true = Node.connect(beacon)
    send(self(), :register)

    {:noreply, state}
  end

  @impl true
  def handle_info(:register, state) do
    :ok =
      GenServer.call(
        {BeaconServer, @beacon},
        {:register, {node(), __MODULE__, @resource, @requirement}}
      )

    {:noreply, state}
  end
end
