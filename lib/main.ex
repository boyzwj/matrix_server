defmodule Main do
  require Logger
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    [
      %{id: :pg, start: {:pg, :start_link, []}}
      | NodeConfig.services()
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: Matrix.Supervisor)
  end

  def config_change(_changed, _new, _removed) do
    IO.inspect("code_change")
    :ok
  end

  @doc """
  热更新所有模块，这个建议只在开发和测试环境使用，会导致进程强行关闭
  """
  def update_all() do
    Logger.debug("begin update modified modules")

    :code.modified_modules()
    |> Enum.map(&update_mod(&1))
  end

  def update_mods(mods) do
    IO.inspect(mods)

    mods
    |> Enum.map(&update_mod(&1))
  end

  def update_mod(mod) do
    :code.purge(mod)
    :code.load_file(mod)
  end
end
