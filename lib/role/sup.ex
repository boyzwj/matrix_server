defmodule Role.Sup do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    role_inferfaces =
      for worker_id <- 1..Application.get_env(:matrix_server, :role_interface_num) do
        {Role.Interface, [worker_id]}
      end

    children = [
      {DynamicSupervisor,
       [
         name: Role.Worker.Sup,
         shutdown: 1000,
         strategy: :one_for_one
       ]}
      | role_inferfaces
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
