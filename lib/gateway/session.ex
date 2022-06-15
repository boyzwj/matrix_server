defmodule GateWay.Session do
  use GenServer
  use Common
  alias GateWay.Session

  defstruct socket: nil,
            transport: nil,
            session_id: nil,
            crypto_key: nil,
            role_id: nil,
            last_recv_index: 0,
            last_send_index: 0,
            recv_buffer: <<>>,
            send_buffer: [],
            send_ref: nil,
            last_heart: 0,
            status: 0

  @behaviour :ranch_protocol
  @timeout 5000

  @send_buffer_queue_len 32
  @base_key "PSZ5TJEF+tEN8TNQjayc2w=="

  @status_unauthorized 0
  @status_authorized 1

  @proto_authorize 1
  @proto_ping 2
  @proto_reconnect 3
  @proto_data_rc4 4
  @proto_data_lz4 5
  @compress_flag 256

  ## API

  def reconnect(role_id, client_last_recv_index) do
    {:global, name(role_id)}
    |> GenServer.call({:reconnect, client_last_recv_index})
  end

  ## CALLBACK
  @impl true
  def start_link(ref, transport, opts) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  @impl true
  def init({ref, transport, _opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: :once)
    session_id = UUID.uuid1()
    status = @status_unauthorized

    state = %__MODULE__{
      socket: socket,
      transport: transport,
      session_id: session_id,
      status: status
    }

    :gen_server.enter_loop(__MODULE__, [], state, @timeout)
  end

  @impl true
  def handle_call({:reconnect, client_last_recv_index}, _from, state) do
    reply = do_reconnect(state, client_last_recv_index)
    {:reply, reply, state}
  end

  @impl true
  def handle_info({:tcp, socket, data}, ~M{socket,transport,recv_buffer} = state) do
    state = state |> decode(recv_buffer <> data)
    :ok = transport.setopts(socket, active: :once)
    {:noreply, state, @timeout}
  end

  def handle_info(:do_send, state) do
    {:noreply, do_send(state)}
  end

  def handle_info({:send_packet, packet}, ~M{send_buffer,send_ref} = state) do
    send_ref && Process.cancel_timer(send_ref)
    len = IO.iodata_length(packet)
    packet = [<<len::16-little>>, packet]
    send_buffer = [packet | send_buffer]

    newstate =
      if IO.iodata_length(send_buffer) >= 1350 do
        ~M{state| send_buffer}
        |> do_send()
      else
        send_ref = Process.send_after(self(), :do_send, 10)
        ~M{state| send_buffer,send_ref}
      end

    {:noreply, newstate}
  end

  def handle_info({:inet_reply, _socket, :ok}, state) do
    {:noreply, state}
  end

  def handle_info(
        {:send_buff, data},
        ~M{send_buffer, send_ref,last_send_index} = state
      ) do
    send_ref && Process.cancel_timer(send_ref)
    data = pkg_pb_data(data, state)
    last_send_index = last_send_index + 1
    Process.put({:pb_cache, last_send_index}, data)
    :erlang.erase({:pb_cache, last_send_index - @send_buffer_queue_len})
    send_buffer = [data | send_buffer]

    newstate =
      if IO.iodata_length(send_buffer) >= 1350 do
        ~M{state| send_buffer,last_send_index}
        |> do_send()
      else
        send_ref = Process.send_after(self(), :do_send, 10)
        ~M{state| send_buffer,send_ref,last_send_index}
      end

    {:noreply, newstate}
  end

  def handle_info(msg, ~M{%Session socket,role_id, transport} = state) do
    Logger.debug("receive #{inspect(msg)} ,  shutdown")
    role_id && RoleSvr.offline(role_id)
    transport.close(socket)
    {:stop, :shutdown, state}
  end

  defp decode(state, <<len::16-little, data::binary-size(len), left::binary>>) do
    state |> decode_body(data) |> decode(left)
  end

  defp decode(state, recv_buffer), do: ~M{state | recv_buffer}

  defp decode_body(
         %__MODULE__{status: @status_unauthorized, session_id: session_id} = state,
         <<@proto_authorize, data::binary>>
       ) do
    with {:ok, role_id} <- Util.dec_rc4(data, @base_key) |> Authorize.authorize() do
      {:ok, _pid} = Role.Interface.start_role_svr(role_id)
      status = @status_authorized
      crypto_key = Util.md5(session_id <> <<role_id::64-little>> <> @base_key)
      data = <<role_id::64-little, session_id::binary>> |> Util.enc_rc4(@base_key)
      packet = <<@proto_authorize, data::binary>>
      :global.re_register_name(name(role_id), self())
      Redis.set("session:#{session_id}", role_id)
      Process.send(self(), {:send_packet, packet}, [:nosuspend])
      :pg.join(__MODULE__, self())
      ~M{state| status,role_id,crypto_key}
    else
      _ ->
        Logger.debug("authorize error")
        state
    end
  end

  defp decode_body(
         %__MODULE__{status: @status_unauthorized} = state,
         <<@proto_reconnect, data::binary>>
       ) do
    <<client_last_recv_index::32-little, role_id::64-little, old_session::binary-size(36)>> =
      Util.dec_rc4(data, @base_key)

    with ^role_id <- Redis.get("session:#{old_session}"),
         {:ok, last_send_index, last_recv_index, send_buffer} <-
           Session.reconnect(role_id, client_last_recv_index) do
      crypto_key = Util.md5(old_session <> <<role_id::64-little>> <> @base_key)
      session_id = old_session

      send_buffer = [
        <<6::16-little, @proto_reconnect, 1, last_recv_index::32-little>> | send_buffer
      ]

      :global.re_register_name(name(role_id), self())

      RoleSvr.reconnect(role_id)

      ~M{state |last_send_index,last_recv_index,crypto_key,session_id,send_buffer}
      |> do_send(false)
    else
      _ ->
        send_buffer = [<<2::16-little, @proto_reconnect, 0>>]
        ~M{state|send_buffer} |> do_send()
    end
  end

  defp decode_body(%__MODULE__{status: @status_unauthorized} = state, _) do
    state
  end

  defp decode_body(state, <<@proto_ping, _client_time::32-little>> = data) do
    now = Util.unixtime()
    Process.send(self(), {:send_packet, data <> <<now::32-little>>}, [:nosuspend])
    ~M{%Session state|last_heart: now}
  end

  defp decode_body(~M{crypto_key} = state, <<@proto_data_rc4, data::binary>>) do
    data = Util.dec_rc4(data, crypto_key)
    decode_proto(state, data)
  end

  defp decode_body(state, <<@proto_data_lz4, data::binary>>) do
    {:ok, data} = :lz4.unpack(data)
    decode_proto(state, data)
  end

  defp decode_body(%__MODULE__{status: @status_authorized} = state, _) do
    state
  end

  defp decode_proto(
         ~M{%Session role_id,last_recv_index} = state,
         <<index::32-little, data::binary>>
       ) do
    with ^last_recv_index <- index - 1 do
      pid = RoleSvr.pid(role_id)

      if is_pid(pid) do
        RoleSvr.client_msg(pid, data)
      else
        {:ok, pid} = Role.Interface.start_role_svr(role_id)
        RoleSvr.client_msg(pid, data)
      end

      ~M{state| last_recv_index: index}
    else
      _ ->
        Logger.warning("receive undefined proto")
        state
    end
  end

  defp pkg_pb_data(pbdata, ~M{last_send_index,crypto_key}) do
    i = last_send_index + 1
    data = [<<i::32-little>>, pbdata]

    if (oldlen = IO.iodata_length(data)) >= @compress_flag do
      {:ok, data} = data |> IO.iodata_to_binary() |> :lz4.pack()
      len = byte_size(data) + 1

      if oldlen >= 512 do
        Logger.warning(
          "Packing big msg: #{pbdata |> IO.iodata_to_binary() |> PB.decode!() |> inspect}  compressed, [#{oldlen} byte] ==> [#{len - 1} byte]  #{Float.round((oldlen - len) * 100 / oldlen, 2)}% reduced"
        )
      end

      <<len::16-little, @proto_data_lz4, data::binary>>
    else
      data = Util.enc_rc4(data, crypto_key)
      len = byte_size(data) + 1
      <<len::16-little, @proto_data_rc4, data::binary>>
    end
  end

  defp do_send(state, reverse \\ true)
  defp do_send(%{send_buffer: []} = state, _reverse), do: state

  defp do_send(~M{send_buffer,socket} = state, reverse) do
    send_buffer = (reverse && :lists.reverse(send_buffer)) || send_buffer

    try do
      :erlang.port_command(socket, send_buffer, [:nosuspend])
    rescue
      ArgumentError ->
        Logger.debug("send fail: #{inspect(socket)},error: #{inspect(send_buffer)}")
    end

    ~M{state| send_buffer: [] ,send_ref: nil}
  end

  defp do_reconnect(~M{last_send_index,last_recv_index}, client_last_recv_index) do
    if last_send_index - client_last_recv_index <= @send_buffer_queue_len do
      send_buffer =
        for i <- (client_last_recv_index + 1)..last_send_index do
          Process.get({:pb_cache, i}, [])
        end

      Process.send_after(self(), :shutdown, @timeout)
      {:ok, last_send_index, last_recv_index, send_buffer}
    else
      Logger.error("reconnect fail !out of cached queue len")
      {:error, :out_of_cache}
    end
  end

  def name(role_id) do
    :"sid_#{role_id}"
  end
end
