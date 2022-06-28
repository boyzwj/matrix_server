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
    IO.inspect("config_change")
    :ok
  end
end
