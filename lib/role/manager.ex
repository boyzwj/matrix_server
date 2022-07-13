defmodule Role.Manager do
  use GenServer
  use Common

  # API
  # ------------------

  def clear_cache(mod, fun, args) do
    :pg.get_members(__MODULE__)
    |> Enum.each(&GenServer.cast(&1, {:clear_cache, mod, fun, args}))
  end

  def start_link(_ops) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    :pg.join(__MODULE__, self())
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:clear_cache, mod, fun, args}, state) do
    Memoize.invalidate(mod, fun, args)
    {:noreply, state}
  end
end
