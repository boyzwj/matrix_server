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
        services("develop", 1)
    end
  end

  def services("game", block_id) do
    FastGlobal.put(:block_id, block_id)
    topologies = Application.get_env(:matrix_server, :topologies)

    [
      {Cluster.Supervisor, [topologies, [name: Matrix.ClusterSupervisor]]},
      {DynamicSupervisor,
       [
         name: Redis.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]},
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]},
      {
        Horde.DynamicSupervisor,
        [
          name: Matrix.DistributedSupervisor,
          shutdown: 1000,
          strategy: :one_for_one,
          members: :auto
        ]
      },
      {Role.Sup, []},
      {Redis.Manager, []},
      {Lobby.Sup, []}
    ]
  end

  def services("gate", block_id) do
    FastGlobal.put(:block_id, block_id)
    topologies = Application.get_env(:matrix_server, :topologies)

    [
      {Cluster.Supervisor, [topologies, [name: Matrix.ClusterSupervisor]]},
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]},
      {GateWay.ListenerSup, []}
    ]
  end

  def services("robot", _block_id) do
    [Robot.Sup, Robot.Manager]
  end

  def services("dsa", _block_id) do
    [{Dsa.Sup, []}]
  end

  def services("develop", block_id) do
    FastGlobal.put(:block_id, block_id)

    [
      {Horde.Registry, [name: Matrix.DBRegistry, keys: :unique, members: :auto]},
      {DynamicSupervisor,
       [
         name: Redis.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]},
      {
        Horde.DynamicSupervisor,
        [
          name: Matrix.DistributedSupervisor,
          shutdown: 1000,
          strategy: :one_for_one,
          members: :auto
        ]
      },
      {Role.Sup, []},
      {Redis.Manager, []},
      {Lobby.Sup, []},
      {Dsa.Sup, []},
      {Api.Sup, []},
      {GateWay.ListenerSup, []}
    ]
  end

  def services(node_type, _) do
    Logger.warning("unknow node type #{inspect(node_type)}")
    []
  end
end
