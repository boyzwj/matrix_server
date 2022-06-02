defmodule NodeConfig do
  use Common

  def services() do
    [node_type, node_id] =
      "#{node()}"
      |> String.split("@")
      |> List.first()
      |> String.split("_")

    services(node_type, String.to_integer(node_id))
  end

  def services("beacon", _) do
    [
      {BeaconServer, name: BeaconServer},
      {DBContact.Interface, name: DBContact.Interface},
      {DBContact.NodeManager, name: DBContact.NodeManager},
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]}
    ]
  end

  def services("db", block_id) do
    [
      {DBService.InterfaceSup, [block_id: block_id]},
      {DBService.WorkerSup, name: DBService.WorkerSup},
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: DBA.Sup,
         shutdown: 1000,
         strategy: :one_for_one,
         members: :auto,
         process_redistribution: :active
       ]}
    ]
  end

  def services("gateway", _) do
    [
      {Gateway.Tcplistener, [Gateway.Tcpclient]}
    ]
  end

  def services("loby", _) do
    []
  end

  def services(node_type, _) do
    Logger.debug("unknow node type #{inspect(node_type)}")
    []
  end
end
