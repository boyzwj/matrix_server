defmodule Dc.Sup do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    port = String.to_integer(System.get_env("DSA_PORT") || "20001")

    children = [
      {Dc.Listener, port: port}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
