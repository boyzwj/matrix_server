defmodule NodeConfig do
  use Common

  @node_all_in_one 0
  @node_gate_way 1
  @node_lobby 2
  @node_db 3

  def services(@node_all_in_one) do
    [{Gateway.Tcplistener, [Gateway.Tcpclient]}, {DB.Redis, []}]
  end

  def services(@node_gate_way) do
    [{Gateway.Tcplistener, [Gateway.Tcpclient]}]
  end

  def services(@node_lobby) do
    []
  end

  def services(@node_db) do
    [{DB.Redis, []}]
  end

  def services(_node_type) do
    []
  end
end
