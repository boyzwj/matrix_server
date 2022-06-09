defmodule RoleSvr do
  use GenServer
  use Common
  defstruct role_id: nil, last_save_time: nil
  @save_interval 5
  @loop_interval 1000

  ## =====API====
  def start(role_id) do
    DynamicSupervisor.start_child(
      Role.Sup,
      {__MODULE__, role_id}
    )
  end

  def exit(role_id) do
    cast(role_id, :exit)
  end

  def client_msg(role_id, msg) do
    cast(role_id, {:client_msg, msg})
  end

  def offline(role_id) do
    cast(role_id, :offline)
  end

  def get_data(role_id, mod) do
    call(role_id, {:apply, mod, :get_data, []})
  end

  def role_id() do
    Process.get(:role_id)
  end

  def child_spec(role_id) do
    %{
      id: "Role_#{role_id}",
      start: {__MODULE__, :start_link, [role_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(role_id) do
    GenServer.start_link(__MODULE__, role_id, name: via(role_id))
  end

  ## ===CALLBACK====
  @impl true
  def init(role_id) do
    Process.put(:role_id, role_id)
    Process.send_after(self(), :secondloop, @loop_interval)
    Process.send(self(), :init, [:nosuspend])
    last_save_time = Util.unixtime()
    {:ok, ~M{%RoleSvr role_id,last_save_time}}
  end

  @impl true
  def handle_info(:init, state) do
    hook(:init)
    {:noreply, state}
  end

  def handle_info(:secondloop, ~M{last_save_time} = state) do
    now = Util.unixtime()
    hook(:secondloop, [now])
    Logger.debug("#{role_id()} do second loop #{now}")
    Process.send_after(self(), :secondloop, @loop_interval)

    if now - last_save_time >= @save_interval do
      hook(:save)
      {:noreply, ~M{state | last_save_time: now }}
    else
      {:noreply, state}
    end
  end

  def handle_info(:safe_stop, state) do
    if Enum.all?(hook(:save)) do
      {:stop, :normal, state}
    else
      Process.send_after(self(), :safe_stop, 1000)
      {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    Logger.warn("unhandle msg: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:client_msg, data}, state) do
    with {:ok, msg} <- PB.PP.decode(data) do
      mod = msg |> Map.get(:__struct__) |> PB.PP.mod()
      mod.h(msg)
    else
      _ ->
        Logger.warning("client msg decode error")
    end

    {:noreply, state}
  end

  def handle_cast(:exit, state) do
    hook(:on_terminate)
    Process.send(self(), :safe_stop, [:nosuspend])
    {:noreply, state}
  end

  def handle_cast(:offline, state) do
    hook(:on_offline)
    {:noreply, state}
  end

  @impl true
  def handle_call({:apply, mod, f, args}, _from, state) do
    reply = :erlang.apply(mod, f, args)
    {:reply, reply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    hook(:save)
    :ok
  end

  defp hook(f, args \\ []) do
    for mod <- PB.PP.modules() do
      try do
        apply(mod, f, args)
      catch
        kind, reason ->
          Logger.error("#{mod} [#{f}] error !! #{kind} , #{reason}, #{inspect(__STACKTRACE__)} ")
          false
      end
    end
  end

  def via(role_id) do
    {:global, :"Role_#{role_id}"}
    # {:via, Horde.Registry, {Matrix.RoleRegistry, role_id}}
  end

  def cast(role_id, msg) do
    role_id
    |> via()
    |> GenServer.cast(msg)
  end

  def call(role_id, msg) do
    role_id
    |> via()
    |> GenServer.call(msg)
  end
end
