defmodule Gateway do
  require Logger

  use Application

  def start(_type, _args) do
    Gateway.Sup.start_link([{Gateway.Tcplistener, [Gateway.Tcpclient]}])
  end
end
