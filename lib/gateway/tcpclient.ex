defmodule Gateway.Tcpclient do
  defstruct socket: nil,
            account: <<>>,
            session_id: <<>>,
            recv_buffer: <<>>,
            last_recv_index: 0,
            send_buffer: [],
            send_buffers: [],
            send_ref: nil,
            player_pid: nil,
            last_heart: 0

  use GenServer
  use Common
  alias Gateway.Tcpclient
  @pool_size 256

  @proto_authorize 101
  @proto_message 104
  @proto_errorcode 105
  @proto_ping 106
  @proto_pong 107

  @second_interval 1000

  # =============   API   ===============
  def get_buffer_info(pid) do
    GenServer.call(pid, :get_buffer_info)
  end

  def send_buff(pid, data) do
    GenServer.cast(pid, {:send_buff, data})
  end

  # ==============  CALLBACK ================

  @impl true
  def init(socket) do
    Process.send_after(self(), :loop, @second_interval)
    Process.put(:sid, self())
    session_id = Ecto.UUID.generate() |> Util.md5() |> Base.encode16()
    {:ok, ~M{%Tcpclient socket, session_id}}
  end

  def handle_call(:get_buffer_info, _from, state) do
    {:reply, {state.last_recv_index, state.send_buffers}, state}
  end

  def handle_info(:stop, ~M{player_pid} = state) do
    if player_pid do
      Role.RoleSvr.stop(player_pid, :normal)
    end

    Logger.debug("tcpclient is stoped")
    {:stop, :normal, state}
  end

  def handle_info({:down, reason}, state) do
    Logger.debug("mod_player is down for reason: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.debug("socket is down reason: #{reason}")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_passive, socket}, ~M{socket} = state) do
    :prim_inet.setopts(socket, active: @pool_size)
    {:noreply, state}
  end

  def handle_info({:inet_reply, socket, _}, ~M{socket} = state) do
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, ~M{socket} = state) do
    Logger.debug("tcp_closed")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket}, ~M{socket} = state) do
    Logger.debug("tcp_error")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket, reason}, ~M{socket} = state) do
    Logger.error("tcp_error reason: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def handle_info({:tcp, socket, data}, ~M{socket,recv_buffer} = state) do
    state = state |> decode(recv_buffer <> data)
    {:noreply, state}
  end

  def handle_info(:loop, ~M{last_heart,player_pid} = state) do
    if last_heart > 0 and Util.unixtime() - last_heart > 30 do
      if player_pid do
        Role.RoleSvr.offline(player_pid)
        {:stop, :normal, state}
      else
        send(self(), :stop)
        {:noreply, state}
      end
    else
      Process.send_after(self(), :loop, @second_interval)
      {:noreply, state}
    end
  end

  def handle_info(:do_send, state) do
    {:noreply, do_send(state)}
  end

  @send_buffers_limit 256
  def handle_cast({:send_buff, data}, ~M{send_buffer, send_ref,send_buffers} = state) do
    send_ref && Process.cancel_timer(send_ref)
    data = pkg_buffer_index(data, send_buffers)
    send_buffer = [data | send_buffer]
    send_buffers = [data | send_buffers] |> Enum.take(@send_buffers_limit)

    newstate =
      if IO.iodata_length(send_buffer) >= 1350 do
        ~M{state| send_buffer,send_buffers}
        |> do_send()
      else
        send_ref = Process.send_after(self(), :do_send, 10)
        ~M{state| send_buffer,send_ref,send_buffers}
      end

    {:noreply, newstate}
  end

  @impl true
  def terminate(_reason, ~M{session_id,player_pid,last_recv_index,send_buffers}) do
    player_pid != nil and send(player_pid, :tcp_closed)
    :ok
  end

  defp decode(state, <<len::16-little, data::binary-size(len), left::binary>>) do
    state |> decode_body(data) |> decode(left)
  end

  defp decode(state, recv_buffer), do: ~M{state | recv_buffer}

  defp decode_body(state, <<@proto_message, recv_index::32-little, body::binary>>) do
    ~M{state|last_recv_index: recv_index} |> handle_proto(body)
  end

  defp decode_body(state, <<@proto_ping, client_time::float>>) do
    state |> handle_ping(client_time)
  end

  defp decode_body(state, <<@proto_authorize, token::binary>>) do
    state |> handle_authorize(token)
  end

  defp do_send(%{send_buffer: []} = state), do: state

  defp do_send(~M{send_buffer,socket} = state) do
    send_buffer = :lists.reverse(send_buffer)

    try do
      :erlang.port_command(socket, send_buffer, [:nosuspend])
    rescue
      ArgumentError ->
        Logger.debug("send fail: #{inspect(socket)},error: #{inspect(send_buffer)}")
    end

    ~M{state| send_buffer: [] ,send_ref: nil}
  end

  defp handle_ping(%Tcpclient{player_pid: nil} = state, client_time) do
    state
  end

  defp handle_ping(
         %Tcpclient{player_pid: player_pid, send_buffer: send_buffer} = state,
         client_time
       ) do
    last_heart = Util.longunixtime() / 1000
    player_pid && send(player_pid, :ping)
    data = <<17::16-little, @proto_pong, last_heart::float, client_time::float>>
    send_buffer = [data | send_buffer]
    ~M{state |last_heart,send_buffer} |> do_send
  end

  defp handle_proto(%Tcpclient{player_pid: nil} = state, data) do
    Logger.warning("unauth msg: #{data} ")
    state
  end

  defp handle_proto(%Tcpclient{player_pid: player_pid} = state, data) do
    Role.RoleSvr.client_msg(player_pid, data)
    state
  end

  defp handle_authorize(%Tcpclient{player_pid: nil} = state, token) do
    state
  end

  defp handle_authorize(%Tcpclient{player_pid: player_pid} = state, token) do
    state
  end

  defp pkg_buffer_index(data, send_buffers) do
    first = send_buffers |> List.first()
    current_buffer_index = get_buffer_index(first) + 1
    len = IO.iodata_length(data) + 5
    [<<len::16-little, @proto_message, current_buffer_index::32-little>> | data]
  end

  def get_buffer_index(nil) do
    0
  end

  def get_buffer_index(data) do
    [<<_len::16-little, _proto_type, index::32-little>> | _d] = data
    index
  end
end
