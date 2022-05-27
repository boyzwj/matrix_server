defmodule Main do
  require Logger
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    node_type = String.to_integer(System.get_env("NODE_TYPE", "0"))

    ([{NodeManager, [node_type]}] ++ NodeConfig.services(node_type))
    |> Supervisor.start_link(strategy: :one_for_one, name: Matrix.Supervisor)
  end

  def config_change(_changed, _new, _removed) do
    :ok
  end
end
