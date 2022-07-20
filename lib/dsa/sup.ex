defmodule Dsa.Sup do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    host = System.get_env("DSA_HOST") || "127.0.0.1"
    port = String.to_integer(System.get_env("DSA_PORT") || "20001")

    children = [
      {Dsa.Svr, [host, port]},
      {DynamicSupervisor,
       [
         name: Dsa.Worker.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
