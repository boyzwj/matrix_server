defmodule DB.Redis do
  defstruct conn: nil, cmd_buffers: []
  use GenServer
  use Common

  @flush_interval 100
  @name __MODULE__

  ## =========== API ============

  def flushdb() do
    ["flushdb"] |> cmd
  end

  def flushall() do
    ["flushall"] |> cmd
  end

  def cmd(cmd) do
    GenServer.call(@name, {:cmd, cmd})
  end

  def get(k) do
    ["GET", k] |> cmd
  end

  def set(k, v) do
    ["SET", k, v] |> cmd
  end

  def hget(k, field) do
    ["HGET", k, field] |> cmd
  end

  def hset(k, field, value) do
    ["HSET", k, field, value] |> cmd
  end

  def hmget(k, fields) do
    ["HGET", k | fields] |> cmd
  end

  def hmset(k, fvs) do
    fvs |> Enum.reduce(["MSET", k], fn {k, v}, acc -> acc ++ [k, v] end) |> cmd
  end

  def hgetall(k) do
    ["HGETALL", k] |> cmd
  end

  def mset(kvs) do
    kvs |> Enum.reduce(["MSET"], fn {k, v}, acc -> acc ++ [k, v] end) |> cmd
  end

  def mget(keys) do
    ["MGET" | keys] |> cmd
  end

  def incr(key) do
    ["INCR", key] |> cmd
  end

  def incrby(key, val) do
    ["INCRBY", key, val]
  end

  def pipeline(cmds) do
    GenServer.call(@name, {:pipeline, cmds})
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: @name)
  end

  ## =========== CALLBACK ============
  @impl true
  def init(_args) do
    opts = Application.get_env(:matrix_server, __MODULE__)

    with {:ok, conn} <- Redix.start_link(opts),
         {:ok, "PONG"} <- Redix.command(conn, ["ping"]) do
      {:ok, %DB.Redis{conn: conn}}
    else
      {:error, reason} ->
        Logger.error("redix connect error, #{inspect(reason)} ")
    end
  end

  @impl true
  def handle_info(:flush, state) do
    # Process.send_after(self(), :flush, @flush_interval)
    # {_reply, state} = flush(state)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warning("unhandled info: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.warning("unhandled cast: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_call({:pipeline, cmds}, _from, ~M{%DB.Redis conn} = state) do
    reply = Redix.pipeline!(conn, cmds)
    {:reply, reply, state}
  end

  def handle_call({:cmd, cmd}, _from, ~M{%DB.Redis conn} = state) do
    reply = Redix.command!(conn, cmd)
    {:reply, reply, state}
  end

  def handle_call(msg, _from, state) do
    Logger.warning("unhandled call: #{inspect(msg)}")
    {:reply, {:error, :unhandle_msg}, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warning("redis server is down, reason: #{inspect(reason)}")
    :ok
  end
end
