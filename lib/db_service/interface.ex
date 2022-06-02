defmodule DBService.Interface do
  use GenServer
  use Common

  @beacon :"beacon_1@127.0.0.1"
  @resource :db_service
  @requirement [:db_contact]

  # 重试间隔：s
  @retry_rate 5

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    block_id = Keyword.get(args, :block_id, 1)
    Logger.debug("interface start ,block_id #{block_id}")
    {:ok, %{db_contact: nil, server_state: :waiting_requirements, block_id: block_id}, 0}
  end

  @impl true
  def handle_info(:timeout, state) do
    send(self(), {:join, @beacon})
    {:noreply, state}
  end

  @impl true
  def handle_info({:join, beacon}, state) do
    case Node.connect(beacon) do
      true ->
        send(self(), :register)

      false ->
        Logger.emergency("Beacon node not up, exiting...")
        :init.stop()
        # Application.stop(:data_service)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:register, state) do
    :ok =
      GenServer.call(
        {BeaconServer, @beacon},
        {:register, {node(), __MODULE__, @resource, @requirement}}
      )

    send(self(), :get_requirements)

    {:noreply, state}
  end

  @impl true
  def handle_info(:get_requirements, ~M{block_id} = state) do
    offer =
      GenServer.call(
        {BeaconServer, @beacon},
        {:get_requirements, node()}
      )

    IO.inspect(offer)

    case offer do
      {:ok, [db_contact | _]} ->
        DBInit.initialize(db_contact.node)

        :ok =
          GenServer.call(
            {DBContact.NodeManager, db_contact.node},
            {:register, node()}
          )

        Horde.DynamicSupervisor.start_child(
          DBA.Sup,
          {DBA, block_id: block_id, worker_num: 10}
        )

        Logger.debug("Requirements accuired, server ready.")
        {:noreply, %{state | db_contact: db_contact.node, server_state: :ready}}

      nil ->
        Logger.debug("Not meeting requirements, retrying in #{@retry_rate}s.")
        :timer.send_after(@retry_rate * 1000, :get_requirements)
        {:noreply, state}
    end
  end
end
