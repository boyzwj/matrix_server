defmodule DBService.Interface do
  use GenServer
  use Common

  @db_worker_num Application.get_env(:matrix_server, :db_worker_num)
  # 重试间隔：s
  @retry_rate 5

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    block_id = Keyword.get(args, :block_id, 1)
    {:ok, %{db_contact: nil, server_state: :waiting_requirements, block_id: block_id}, 0}
  end

  @impl true
  def handle_info(:timeout, state) do
    if Node.list() == [] do
      Logger.debug("start DBManager")

      Horde.DynamicSupervisor.start_child(
        DBManager.Sup,
        {DBManager, []}
      )
    end

    Process.send_after(self(), :register, 1000)
    {:noreply, state}
  end

  @impl true
  def handle_info(:register, state) do
    with {:ok, db_list} <- DBManager.get_db_list(),
         :ok <- DBManager.register(node()) do
      DBInit.initialize(db_list)
      DBManager.ready(node())

      1..@db_worker_num
      |> Enum.each(&DBService.WorkerSup.start_child(&1))

      {:noreply, state}
    else
      _err ->
        Logger.warning("remote db not ready, waiting and retry..")
        Process.send_after(self(), :register, @retry_rate * 1000)
        {:noreply, state}
    end
  end
end
