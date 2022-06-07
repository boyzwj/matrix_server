defmodule NodeConfig do
  use Common

  def services() do
    with [node_type, node_id] <-
           "#{node()}"
           |> String.split("@")
           |> List.first()
           |> String.split("_") do
      services(node_type, String.to_integer(node_id))
    else
      _ ->
        services("s", 1)
    end
  end

  def services("s", block_id) do
    topologies = [
      game_server: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    [
      {Gateway.Tcplistener, [Gateway.Tcpclient]},
      {DynamicSupervisor, name: Role.Sup, strategy: :one_for_one},
      {Cluster.Supervisor, [topologies, [name: Chat.ClusterSupervisor]]},
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]},
      {Horde.DynamicSupervisor,
       [
         name: DBManager.Sup,
         shutdown: 1000,
         strategy: :one_for_one,
         members: :auto,
         process_redistribution: :passive
       ]},
      {DBService.InterfaceSup, [block_id: block_id]},
      {GID, [block_id: block_id]},
      {DBService.WorkerSup, name: DBService.WorkerSup}
    ]
  end

  def services(node_type, _) do
    Logger.debug("unknow node type #{inspect(node_type)}")
    []
  end
end
