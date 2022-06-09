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

  def loop(%Worker{id: id, status: @status_init} = state) do
    addr = String.to_charlist(System.get_env("ADDR") || "127.0.0.1")
    port = String.to_integer(System.get_env("PORT") || "4200")

    with {:ok, socket} <- :gen_tcp.connect(addr, port, [:binary, active: true]) do
      Logger.debug("socket connected")
      status = @status_connected
      ~M{state| socket,status} |> loop()
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
    state |> do_send(data)
  end

  def loop(%Worker{status: @status_offline} = state) do
    state
  end

  defp do_send(~M{socket} = state, data) do
    len = byte_size(data)
    :ok = :gen_tcp.send(socket, <<len::16-little, data::binary>>)
    state
  end
end
