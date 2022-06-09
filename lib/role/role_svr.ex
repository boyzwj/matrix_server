defmodule RoleSvr do
  use GenServer
  use Common
  defstruct role_id: nil, last_save_time: nil, status: 0, last_msg_time: nil

  @status_init 0
  @status_online 1
  @status_offline 2

  @save_interval 5
  @loop_interval 1000

  ## =====API====
  def start(role_id) do
    DynamicSupervisor.start_child(
      Role.Sup,
      {__MODULE__, role_id}
    )
  end

  def pid(role_id) do
    :global.whereis_name(name(role_id))
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
    now = Util.unixtime()
    last_save_time = now
    last_msg_time = now
    status = @status_init
    {:ok, ~M{%RoleSvr role_id,last_save_time,status,last_msg_time}}
  end

  @impl true
  def handle_info(:init, state) do
    hook(:init)
    {:noreply, state}
  end

  def handle_info(:secondloop, state) do
    now = Util.unixtime()
    hook(:secondloop, [now])
    # Logger.debug("#{role_id()} do second loop #{now}")
    Process.send_after(self(), :secondloop, @loop_interval)

    state =
      state
      |> check_save(now)
      |> check_down(now)

    {:noreply, state}
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
  def handle_cast({:client_msg, data}, state) when is_binary(data) do
    with {:ok, msg} <- PB.PP.decode(data) do
      mod = msg |> Map.get(:__struct__) |> PB.PP.mod()
      mod.h(msg)
    else
      _ ->
        Logger.warning("client msg decode error")
    end

    last_msg_time = Util.unixtime()
    status = @status_online
    {:noreply, ~M{%RoleSvr state | status,last_msg_time}}
  end

  def handle_cast(:exit, state) do
    Logger.debug("exit role svr #{state.role_id} ")
    hook(:on_terminate)
    Process.send(self(), :safe_stop, [:nosuspend])
    {:noreply, state}
  end

  def handle_cast(:offline, state) do
    hook(:on_offline)
    status = @status_offline
    {:noreply, ~M{%RoleSvr state|status}}
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

  defp check_save(~M{%RoleSvr last_save_time} = state, now) do
    if now - last_save_time >= @save_interval do
      hook(:save)
      ~M{state | last_save_time: now }
    else
      state
    end
  end

  defp check_down(~M{%RoleSvr last_msg_time,status} = state, now) do
    timeout = now - last_msg_time

    cond do
      # status == @status_init && timeout >= 5 ->
      #   Process.send(self(), :exit, [:nosuspend])
      status == @status_offline && timeout >= 5 ->
        cast(self(), :exit)

      true ->
        :ignore
    end

    state
  end

  def name(role_id) do
    :"Role_#{role_id}"
  end

  def via(role_id) do
    {:global, name(role_id)}
    # {:via, Horde.Registry, {Matrix.RoleRegistry, role_id}}
  end

  def cast(role_id, msg) when is_integer(role_id) do
    role_id
    |> via()
    |> GenServer.cast(msg)
  end

  def cast(pid, msg) when is_pid(pid) do
    pid |> GenServer.cast(msg)
  end

  def call(role_id, msg) when is_integer(role_id) do
    role_id
    |> via()
    |> GenServer.call(msg)
  end

  def call(pid, msg) when is_pid(pid) do
    pid |> GenServer.call(msg)
  end
end
