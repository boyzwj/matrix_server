defmodule Gateway.Tcplistener do
  use GenServer
  use Common
  alias Gateway.Tcplistener
  defstruct port: nil, tcp_opts: [], acceptor_pids: [], mod: nil, socket: nil
  @acceptor_num 10
  @tcp_opts [
    :binary,
    packet: 0,
    active: false,
    reuseaddr: true,
    nodelay: true,
    delay_send: false,
    send_timeout: 5000,
    keepalive: false,
    exit_on_close: true
  ]

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  def init(args) do
    [mod] = args
    port = String.to_integer(System.get_env("PORT") || "4200")
    :erlang.send(self(), :listen)
    {:ok, %Tcplistener{port: port, tcp_opts: @tcp_opts, mod: mod}}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info(:listen, ~M{port,tcp_opts, mod} = state) do
    Logger.debug("begin listen at port #{port}")

    case :gen_tcp.listen(port, tcp_opts) do
      {:error, reason} ->
        reason |> inspect |> Logger.error()
        {:stop, :normal, state}

      {:ok, socket} ->
        acceptor_pids =
          for _ <- 1..@acceptor_num do
            Gateway.Tcpaccepter.start(socket, mod)
          end

        state = ~M{state |acceptor_pids,socket}
        {:noreply, state}
    end
  end
end
