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
        services("aio", 1)
    end
  end

  def services("game", block_id) do
    FastGlobal.put(:block_id, block_id)
    topologies = Application.get_env(:matrix_server, :topologies)

    role_inferfaces =
      for worker_id <- 1..Application.get_env(:matrix_server, :role_interface_num) do
        {Role.Interface, [worker_id]}
      end

    [
      {Cluster.Supervisor, [topologies, [name: Matrix.ClusterSupervisor]]},
      {DynamicSupervisor,
       [
         name: Role.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]},
      {DynamicSupervisor,
       [
         name: Redis.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]},
      {Redis.Manager, []}
    ] ++ role_inferfaces
  end

  def services("gate", block_id) do
    FastGlobal.put(:block_id, block_id)
    topologies = Application.get_env(:matrix_server, :topologies)

    [
      {Cluster.Supervisor, [topologies, [name: Matrix.ClusterSupervisor]]},
      {GW.ListenerSup, []}
    ]
  end

  def services("robot", _block_id) do
    [{Robot.Sup, name: Robot.Sup}, {Robot.Manager, []}]
  end

  def services(node_type, _) do
    Logger.debug("unknow node type #{inspect(node_type)}")
    []
  end
end
