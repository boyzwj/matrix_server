defmodule Redis.Manager do
  use GenServer
  use Common

  def start_link(ops) do
    GenServer.start_link(__MODULE__, [ops], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Logger.debug("Redis manager start")
    interval = Util.rand(1, 100)
    Process.send_after(self(), :start_worker, interval)
    {:ok, {}}
  end

  @impl true
  def handle_info(:start_worker, state) do
    for worker_id <- 1..Application.get_env(:matrix_server, :db_worker_num, 8) do
      Horde.DynamicSupervisor.start_child(
        Matrix.DistributedSupervisor,
        {Redis, worker_id}
      )
    end

    {:noreply, state}
  end
end
