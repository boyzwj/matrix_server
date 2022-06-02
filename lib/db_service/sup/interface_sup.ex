defmodule DBService.InterfaceSup do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    args = [
      {DBService.Interface, args}
    ]

    Supervisor.init(args, strategy: :one_for_one)
  end
end
