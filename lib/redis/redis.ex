defmodule Redis do
  use GenServer
  use Common
  defstruct conns: {}
  @db_worker_num Application.get_env(:matrix_server, :db_worker_num)
  @redis_blocks Application.get_env(:matrix_server, :redis_blocks)

  ###       API          ###
  def hset(key, field, value) do
    select_call("HSET", [key, field, value])
  end

  def hget(key, field) do
    select_call("HGET", [key, field])
  end

  def hgetall(key) do
    select_call("HGETALL", [key])
  end

  def set(key, value) do
    select_call("SET", [key, value])
  end

  def get(key) do
    select_call("GET", [key])
  end

  def incr(key) do
    select_call("INCR", [key])
  end

  def clearall() do
    select_call("FLUSHALL", [])
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
    Logger.debug("Redis agent start")
    interval = Util.rand(1, 500)
    Process.send_after(self(), :connect_all, interval)
    {:ok, %Redis{}}
  end

  @impl true
  def handle_info(:connect_all, state) do
    conns =
      for {host, port} <- @redis_blocks do
        {:ok, conn} = Redix.start_link(host: host, port: port)
        conn
      end
      |> List.to_tuple()

    {:noreply, ~M{%Redis state| conns}}
  end

  @impl true

  def handle_call({:cmd, cmd, args}, _from, state) do
    reply = do_handle(state, cmd, args)
    {:reply, reply, state}
  end

  def handle_call(:clearall, _from, ~M{%Redis conns} = state) do
    reply =
      conns
      |> Tuple.to_list()
      |> Enum.each(&Redis.Cmd.clear(&1))

    {:reply, reply, state}
  end

  def via_tuple(worker_id) do
    :"redis#{worker_id}"
  end

  defp worker_by_key(key) do
    worker_id = :erlang.phash2(key, @db_worker_num) + 1
    via_tuple(worker_id)
  end

  defp select_call(cmd, []) do
    worker_by_key(0)
    |> GenServer.call({:cmd, cmd, []})
  end

  defp select_call(cmd, [key | _] = args) do
    worker_by_key(key)
    |> GenServer.call({:cmd, cmd, args})
  end

  defp do_handle(~M{conns} = _state, cmd, []) do
    index = Util.rand(0, tuple_size(conns) - 1)
    conn = elem(conns, index)
    Redis.Cmd.handle(conn, cmd, [])
  end

  defp do_handle(~M{conns} = _state, cmd, [key | _] = args) do
    index = :erlang.phash2(key, tuple_size(conns))
    conn = elem(conns, index)
    Redis.Cmd.handle(conn, cmd, args)
  end
end
