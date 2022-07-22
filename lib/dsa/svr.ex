defmodule Dsa.Svr do
  use GenServer
  use Common
  @loop_interval 1000

  ## ===================  API ==========================

  def start_game(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  def end_game(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  ### =====================callback ======================
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :secondloop, @loop_interval)
    state = Dsa.init()
    {:ok, state}
  end

  @impl true
  def handle_info(:secondloop, %Dsa{} = state) do
    now = Util.unixtime()
    Process.send_after(self(), :secondloop, @loop_interval)
    state = ~M{state|now} |> Dsa.secondloop()
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    msg = PB.decode!(data)
    state = Dsa.handle(state, msg)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, ~M{recv_buffer} = state) do
    state = state |> decode(recv_buffer <> data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    state = Dsa.tcp_closed(state, socket)
    {:noreply, state}
  end

  @impl true
  def handle_call({func, arg}, _from, %Dsa{} = state) do
    try do
      {reply, state} = apply(Dsa, func, [state, arg])
      {:reply, reply, state}
    catch
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(msg, _from, state) do
    Logger.warn("unhandle call : #{msg}")
    reply = :ignore
    {:reply, reply, state}
  end

  @impl true
  def handle_cast({func, arg}, %Dsa{} = state) do
    try do
      state = apply(Dsa, func, [state, arg])
      {:noreply, state}
    catch
      error ->
        Logger.error("handle cast error : #{error}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(msg, state) do
    Logger.warn("unhandle cast : #{msg}")
    {:noreply, state}
  end

  defp decode(state, <<len::16-little, data::binary-size(len), left::binary>>) do
    state |> decode_body(data) |> decode(left)
  end

  defp decode(state, recv_buffer), do: ~M{state | recv_buffer}

  defp decode_body(state, data) do
    msg = Dc.Pb.decode!(data)
    GenServer.cast(self(), {:dc_msg, msg})
    state
  end
end
