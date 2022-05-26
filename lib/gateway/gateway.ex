defmodule Gateway do
  require Logger

  use Application

  def start(_type, _args) do
    Logger.info("gateway starting ...")
    {:ok, sup_id} = Gateway.Sup.start_link([])
    port = String.to_integer(System.get_env("PORT") || "4200")
    {Gateway.Tcplistener, [port, Gateway.Tcpclient]} |> Gateway.Sup.start_child()
    {:ok, sup_id}
  end
end
