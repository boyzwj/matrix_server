defmodule Robot.Manager do
  use GenServer
  use Common

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_init_arg) do
    Process.send_after(self(), :start, 1000)
    {:ok, %{}}
  end

  @impl true

  def handle_info(:start, state) do
    num = String.to_integer(System.get_env("ROBOT_NUM") || "1")

    for id <- 1..num do
      Robot.Sup.start_child(id)
    end

    {:noreply, state}
  end
end
