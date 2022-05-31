defmodule NodeConfig do
  use Common

  def services() do
    "#{node()}"
    |> String.split("@")
    |> List.first()
    |> String.split("_")
    |> List.first()
    |> services()
  end

  def services("beacon") do
    [
      {BeaconServer, name: BeaconServer},
      {DBContact.Interface, name: DBContact.Interface},
      {DBContact.NodeManager, name: DBContact.NodeManager}
    ]
  end

  def services("db") do
    [
      {DBService.InterfaceSup, name: DBService.InterfaceSup},
      {DBService.WorkerSup, name: DBService.WorkerSup}
    ]
  end

  def services("gateway") do
    [
      {Gateway.Tcplistener, [Gateway.Tcpclient]}
    ]
  end

  def services("loby") do
    []
  end

  def services(node_type) do
    Logger.debug("unknow node type #{inspect(node_type)}")
    []
  end
end
