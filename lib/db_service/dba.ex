defmodule DBA do
  use GenServer
  require Logger

  ### =======================API ============================

  @db_block_num Application.get_env(:matrix_server, :db_block_num)
  def dirty_read(tab, key) do
    block_id = :erlang.phash2({tab, key}, @db_block_num) + 1
    Logger.debug("read from block: #{block_id}")
    GenServer.call(via_tuple(block_id), {:dirty_read, tab, key})
  end

  def child_spec(opts) do
    block_id = Keyword.get(opts, :block_id, 1)
    worker_num = Keyword.fetch!(opts, :worker_num)

    %{
      id: "#{__MODULE__}_#{block_id}",
      start: {__MODULE__, :start_link, [block_id, worker_num]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(block_id, worker_num) do
    GenServer.start_link(__MODULE__, worker_num, name: via_tuple(block_id))
  end

  @impl true
  def init(worker_num) do
    Logger.debug("New DB agent connected  worker_num: #{worker_num}")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:dirty_read, tab, key}, _from, state) do
    Logger.debug("do dirty read")

    reply =
      case :mnesia.dirty_read(tab, key) do
        [t] -> Memento.Query.Data.load(t)
        [] -> nil
      end

    {:reply, reply, state}
  end

  def via_tuple(block_id), do: {:via, Horde.Registry, {Matrix.DBRegistry, block_id}}
end
