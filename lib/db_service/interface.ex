defmodule DBService.Interface do
  use GenServer

  require Logger

  @beacon :"beacon_1@127.0.0.1"
  @resource :db_service
  @requirement [:db_contact]

  # 重试间隔：s
  @retry_rate 5

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_init_arg) do
    {:ok, %{db_contact: nil, server_state: :waiting_requirements}, 0}
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
  def handle_info(:get_requirements, state) do
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

        Logger.debug("Requirements accuired, server ready.")
        {:noreply, %{state | db_contact: db_contact.node, server_state: :ready}}

      nil ->
        Logger.debug("Not meeting requirements, retrying in #{@retry_rate}s.")
        :timer.send_after(@retry_rate * 1000, :get_requirements)
        {:noreply, state}
    end
  end
end
