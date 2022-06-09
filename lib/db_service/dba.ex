defmodule DBA do
  use GenServer
  require Logger

  ### =======================API ============================
  @db_worker_num Application.get_env(:matrix_server, :db_worker_num)
  def dirty_read(tab, key) do
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    GenServer.call(via_tuple(worker_id), {:dirty_read, tab, key})
  end

  def dirty_write(data) when is_struct(data) do
    tab = data.__struct__
    [keyfield | _] = tab.__info__.attributes
    key = data |> Map.get(keyfield)
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    GenServer.call(via_tuple(worker_id), {:dirty_write, data})
  end

  def read(tab, key) do
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    GenServer.call(via_tuple(worker_id), {:read, tab, key})
  end

  def write(data) when is_struct(data) do
    tab = data.__struct__
    [keyfield | _] = tab.__info__.attributes
    key = data |> Map.get(keyfield)
    worker_id = :erlang.phash2({tab, key}, @db_worker_num) + 1
    GenServer.call(via_tuple(worker_id), {:write, data})
  end

  def child_spec(opts) do
    worker_id = Keyword.fetch!(opts, :worker_id)

    %{
      id: "#{__MODULE__}_#{worker_id}",
      start: {__MODULE__, :start_link, [worker_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(worker_id))
  end

  @impl true
  def init(_args) do
    # Logger.debug("New DB agent connected  worker_num: #{worker_num}")
    {:ok, %{}}
  end

  @impl true
  def handle_call({:dirty_read, tab, key}, _from, state) do
    # Logger.debug("do dirty read #{inspect(self())}")

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

  @impl true
  def handle_call({:read, tab, key}, _from, state) do
    # Logger.debug("do dirty read #{inspect(self())}")
    reply = Memento.transaction!(fn -> Memento.Query.read(tab, key) end)
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:write, data}, _from, state) do
    # Logger.debug("do dirty read")
    reply = Memento.transaction!(fn -> Memento.Query.write(data) end)
    {:reply, reply, state}
  end

  def via_tuple(worker_id) do
    :"dba#{worker_id}"
  end
end
