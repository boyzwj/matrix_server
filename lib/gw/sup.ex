defmodule GW.ListenerSup do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true

  def init({}) do
    port = String.to_integer(System.get_env("PORT") || "4200")

    children = [
      {GW.GameListener, port: port}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
