defmodule Robot.Worker do
  defstruct id: nil,
            addr: nil,
            port: nil,
            socket: nil,
            status: 0,
            role_id: 0,
            session_id: nil,
            crypto_key: nil,
            last_recv_index: 0,
            last_send_index: 0,
            recv_buffer: <<>>,
            lag: 0

  use GenServer
  use Common
  alias Robot.Worker
  alias Robot.FSM

  @base_key "PSZ5TJEF+tEN8TNQjayc2w=="

  @loop_interval 1000

  @proto_authorize 1
  @proto_ping 2
  @proto_reconnect 3
  @proto_data_rc4 4
  @proto_data_lz4 5
  @compress_flag 256

  @status_init 0
  # @status_connected 1
  @status_online 2
  @status_offline 3
  # @status_reconnecting 4

  ### =================== API =======================

  def send_buf(~M{%Worker last_send_index,crypto_key} = state, msg) do
    last_send_index = last_send_index + 1
    body = PB.encode!(msg)
    data = [<<last_send_index::32-little>> | body]

    fdata =
      if IO.iodata_length(data) >= @compress_flag do
        {:ok, data} = :lz4.pack(data)
        <<@proto_data_rc4, data::binary>>
      else
        <<@proto_data_rc4, Util.enc_rc4(data, crypto_key)::binary>>
      end

    do_send(~M{state | last_send_index}, fdata)
  end

  def send_ping(state) do
    now = Util.unixtime()
    data = <<@proto_ping, now::32-little>>
    state |> do_send(data)
  end

  def send_authorize(%Worker{id: id} = state) do
    data = Util.enc_rc4("Robot_#{id}", @base_key)
    state |> do_send(<<@proto_authorize, data::binary>>)
  end

  def send_reconnect(~M{%Worker last_recv_index, role_id, session_id} = state) do
    data =
      Util.enc_rc4(
        <<last_recv_index::32-little, role_id::64-little, session_id::binary>>,
        @base_key
      )

    state |> do_send(<<@proto_reconnect, data::binary>>)
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
    GenServer.start_link(__MODULE__, [worker_id], name: via_tuple(worker_id))
  end

  @impl true
  def init([worker_id]) do
    Logger.debug("Robot #{worker_id}  started")
    Process.send_after(self(), :loop, 500)
    {:ok, %Worker{id: worker_id}}
  end

  ### ================== CALLBACK ==================
  @impl true
  def handle_info(:loop, state) do
    state = FSM.loop(state)
    Process.send_after(self(), :loop, @loop_interval)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, ~M{recv_buffer} = state) do
    state = state |> decode(recv_buffer <> data)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    status = @status_offline
    {:noreply, ~M{state|status}}
  end

  def handle_info(msg, state) do
    Logger.debug("receive msg #{inspect(msg)}")
    {:noreply, state}
  end

  def via_tuple(worker_id) do
    :"robot_#{worker_id}"
  end

  defp decode(state, <<len::16-little, data::binary-size(len), left::binary>>) do
    state |> decode_body(data) |> decode(left)
  end

  defp decode(state, recv_buffer), do: ~M{state | recv_buffer}

  def decode_body(state, <<@proto_authorize, data::binary>>) do
    <<role_id::64-little, session_id::binary>> = Util.dec_rc4(data, @base_key)
    Logger.debug("authorize ok, session_id: #{session_id}")
    crypto_key = Util.md5(session_id <> <<role_id::64-little>> <> @base_key)

    ~M{%Worker state|role_id,session_id,crypto_key}
    |> FSM.login_ok()
  end

  def decode_body(state, <<@proto_reconnect, 1, server_last_recv_index::32-little>>) do
    Logger.debug("resume session success ...")
    status = @status_online
    last_send_index = server_last_recv_index
    ~M{state|status,last_send_index}
  end

  def decode_body(state, <<@proto_reconnect, 0>>) do
    last_send_index = 0
    last_recv_index = 0
    recv_buffer = <<>>
    status = @status_init
    ~M{state|status,last_send_index,last_recv_index,recv_buffer}
  end

  def decode_body(state, <<@proto_ping, client_time::32-little, _server_time::32-little>>) do
    now = Util.unixtime()
    lag = (now - client_time) |> div(2)
    # Logger.debug("ping back, lag : #{lag}")
    ~M{%Worker state | lag}
  end

  def decode_body(~M{crypto_key} = state, <<@proto_data_rc4, data::binary>>) do
    data = Util.dec_rc4(data, crypto_key)
    decode_proto(state, data)
  end

  def decode_body(state, <<@proto_data_lz4, data::binary>>) do
    {:ok, data} = :lz4.unpack(data)
    decode_proto(state, data)
  end

  def decode_body(state, _) do
    state
  end

  defp decode_proto(
         ~M{%Worker last_recv_index} = state,
         <<index::32-little, data::binary>>
       ) do
    # Logger.debug("receive index #{index}, last receive index #{last_recv_index}")

    with ^last_recv_index <- index - 1 do
      msg = PB.decode!(data)

      ~M{state| last_recv_index: index}
      |> Robot.Handler.h(msg)
    else
      _ ->
        Logger.warning("receive undefined proto")
        state
    end
  end

  defp do_send(~M{socket} = state, data) do
    len = byte_size(data)
    :ok = :gen_tcp.send(socket, <<len::16-little, data::binary>>)
    state
  end
end
