defmodule Robot.FSM do
  use Common
  alias Robot.Worker

  @status_init 0
  @status_connected 1
  @status_online 2
  @status_offline 3
  @status_reconnecting 4

  def server_list() do
    [{'127.0.0.1', 4001}]
    # [{'127.0.0.1', 4001}, {'127.0.0.1', 4002}]
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

  def loop(%Worker{status: @status_connected} = state) do
    Worker.send_authorize(state)
  end

  def loop(%Worker{status: @status_online} = state) do
    state
    |> Worker.send_ping()
    |> Worker.send_buf(%Chat.Chat2S{content: "这是一条聊天信息"})
  end

  def loop(%Worker{status: @status_offline} = state) do
    state
  end

  def handle(state, msg) do
    Logger.warning("unhandle msg: #{inspect(msg)}")
    state
  end

  def login_ok(state) do
    status = @status_online
    ~M{%Worker state| status}
  end
end
