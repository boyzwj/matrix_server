defmodule DB.Redis do
  defstruct conn: nil, cmd_buffers: []
  use GenServer
  use Common

  @flush_interval 100
  @name __MODULE__

  ## =========== API ============
  def cmd(cmd) do
    GenServer.call(@name, {:cmd, cmd})
  end

  def get(k) do
    ["GET", k] |> cmd
  end

  def set(k, v) do
    ["SET", k, v] |> cmd
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
    {:ok, conn} = Redix.start_link(opts)
    # Process.send_after(self(), :flush, @flush_interval)
    {:ok, %DB.Redis{conn: conn}}
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
    reply = Redix.pipeline(conn, cmds)
    {:reply, reply, state}
  end

  def handle_call({:cmd, cmd}, _from, ~M{%DB.Redis conn} = state) do
    reply = Redix.command(conn, cmd)
    {:reply, reply, state}
  end

  def handle_call(msg, _from, state) do
    Logger.warning("unhandled call: #{inspect(msg)}")
    {:reply, {:error, :unhandle_msg}, state}
  end

  # defp flush(%DB.Redis{cmd_buffers: []} = state) do
  #   {{:ok, 0}, state}
  # end

  # defp flush(~M{%DB.Redis conn,cmd_buffers} = state) do
  #   case Redix.pipeline(conn, cmd_buffers) do
  #     {:ok, result} ->
  #       {{:ok, result}, ~M{state | cmd_buffers: []}}

  #     {:error, error} ->
  #       {{:error, error}, state}
  #   end
  # end
end
