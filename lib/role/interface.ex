defmodule Role.Interface do
  use GenServer
  use Common
  defstruct state: nil

  def start_role_svr(role_id) do
    case roleid_to_pid(role_id)
         |> GenServer.call({:start_role_svr, role_id}, 10_000) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end

  defp roleid_to_pid(role_id) do
    pids = :pg.get_members(Role.Interface)
    index = :erlang.phash2(role_id, length(pids)) + 1
    :lists.nth(index, pids)
  end

  def child_spec(worker_id) do
    %{
      id: :"role_interface_#{worker_id}",
      start: {__MODULE__, :start_link, []},
      shutdown: 10_000,
      restart: :transient,
      type: :worker
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_args) do
    :pg.join(__MODULE__, self())
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call({:start_role_svr, role_id}, _from, state) do
    reply = DynamicSupervisor.start_child(Role.Worker.Sup, {Role.Svr, role_id})
    {:reply, reply, state}
  end
end
