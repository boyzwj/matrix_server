defmodule Robot.FSM do
  use Common
  alias Robot.Worker
  @base_key "PSZ5TJEF+tEN8TNQjayc2w=="

  @proto_authorize 1
  @proto_ping 2
  @proto_data 3
  @proto_reconnect 4

  @status_init 0
  @status_connected 1
  @status_online 2
  @status_offline 3

  def server_list() do
    [{'127.0.0.1', 4001}, {'127.0.0.1', 4002}]
  end

  def loop(%Worker{id: id, status: @status_init} = state) do
    {addr, port} = Util.rand_list(server_list())
    # addr = String.to_charlist(System.get_env("ADDR") || "127.0.0.1")
    # port = String.to_integer(System.get_env("PORT") || "4200")
    with {:ok, socket} <- :gen_tcp.connect(addr, port, [:binary, active: true]) do
      Logger.debug("socket connected")
      status = @status_connected
      ~M{%Worker state| socket,status} |> loop()
    else
      err ->
        Logger.debug("robot #{id} connect error #{inspect(err)}")
        state
    end
  end

  def loop(%Worker{id: id, status: @status_connected} = state) do
    data = Util.enc_rc4("Robot_#{id}", @base_key)
    state |> do_send(<<@proto_authorize, data::binary>>)
  end

  def loop(%Worker{status: @status_online} = state) do
    now = Util.unixtime()
    data = <<@proto_ping, now::32-little>>

    state
    |> do_send(data)
    |> send_buf(%System.Ping2S{time: Util.unixtime()})
  end

  def loop(%Worker{status: @status_offline} = state) do
    state
  end

  defp send_buf(~M{%Worker last_send_index,crypto_key} = state, msg) do
    last_send_index = last_send_index + 1
    body = PB.PP.encode!(msg)
    data = [<<last_send_index::32-little>> | body] |> Util.enc_rc4(crypto_key)
    do_send(~M{state | last_send_index}, <<@proto_data, data::binary>>)
  end

  defp do_send(~M{socket} = state, data) do
    len = byte_size(data)
    :ok = :gen_tcp.send(socket, <<len::16-little, data::binary>>)
    state
  end

  def decode_body(state, <<@proto_authorize, data::binary>>) do
    <<role_id::64-little, session_id::binary>> = Util.dec_rc4(data, @base_key)
    Logger.debug("authorize ok, session_id: #{session_id}")
    crypto_key = Util.md5(session_id <> <<role_id::64-little>> <> @base_key)
    status = @status_online
    ~M{%Worker state|role_id,session_id,crypto_key,status}
  end

  def decode_body(state, <<@proto_ping, client_time::32-little, _server_time::32-little>>) do
    now = Util.unixtime()
    lag = (now - client_time) |> div(2)
    # Logger.debug("ping back, lag : #{lag}")
    ~M{%Worker state | lag}
  end
end
