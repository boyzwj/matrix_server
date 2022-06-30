defmodule Lobby.Sup do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {Lobby.Svr, []}
    ]

    :ets.new(Room, [
      :named_table,
      {:keypos, 1},
      {:write_concurrency, true},
      {:read_concurrency, true}
    ])

    Supervisor.init(children, strategy: :one_for_one)
  end
end
