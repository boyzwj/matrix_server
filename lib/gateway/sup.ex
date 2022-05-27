defmodule Gateway.Sup do
  use DynamicSupervisor

  @name __MODULE__
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: @name)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(child) do
    DynamicSupervisor.start_child(@name, child)
  end
end
