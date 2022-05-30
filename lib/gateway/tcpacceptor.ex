defmodule Gateway.Tcpaccepter do
  use Common
  @send_timeout 1000
  @options [
             :binary,
             activte: 8,
             send_timeout: @send_timeout
           ] ++ [{:raw, 6, 8, <<30::native-32>>}]

  def start(socket, mod) do
    :erlang.spawn_link(fn -> tcp_accepter(socket, mod) end)
  end

  def tcp_accepter(socket, mod) do
    with {:ok, s} <- :gen_tcp.accept(socket),
         {:ok, pid} <- mod.start(s),
         :ok <- :gen_tcp.controlling_process(s, pid) do
      :prim_inet.setopts(s, @options)
    else
      {:error, :closed} ->
        :ok

      err ->
        err |> inspect |> Logger.error()
    end

    tcp_accepter(socket, mod)
  end
end
