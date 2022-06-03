defmodule DBA do
  use GenServer
  require Logger

  ### =======================API ============================

  @db_block_num Application.get_env(:matrix_server, :db_block_num)
  @db_worker_num Application.get_env(:matrix_server, :db_worker_num)
  def dirty_read(tab, key) do
    block_id = :erlang.phash2({tab, key}, @db_block_num) + 1
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    # Logger.debug("read from block: #{block_id}")
    GenServer.call(via_tuple(block_id, worker_id), {:dirty_read, tab, key})
  end

  def dirty_write(data) when is_struct(data) do
    tab = data.__struct__
    key = data.id
    block_id = :erlang.phash2({tab, key}, @db_block_num) + 1
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    # Logger.debug("write to block: #{block_id}")
    GenServer.call(via_tuple(block_id, worker_id), {:dirty_write, data})
  end

  def child_spec(opts) do
    block_id = Keyword.get(opts, :block_id, 1)
    worker_id = Keyword.fetch!(opts, :worker_id)

    %{
      id: "#{__MODULE__}_#{block_id}",
      start: {__MODULE__, :start_link, [block_id, worker_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(block_id, worker_id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(block_id, worker_id))
  end

  @impl true
  def init(_args) do
    # Logger.debug("New DB agent connected  worker_num: #{worker_num}")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:dirty_read, tab, key}, _from, state) do
    Logger.debug("do dirty read #{inspect(self())}")

    reply =
      case :mnesia.dirty_read(tab, key) do
        [t] -> Memento.Query.Data.load(t)
        [] -> nil
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:dirty_write, data}, _from, state) do
    # Logger.debug("do dirty read")

    reply =
      data
      |> Memento.Query.Data.dump()
      |> :mnesia.dirty_write()

    {:reply, reply, state}
  end

  def via_tuple(block_id, worker_id),
    do: {:via, Horde.Registry, {Matrix.DBRegistry, {block_id, worker_id}}}
end
