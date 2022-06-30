defmodule Role.Svr do
  use GenServer
  use Common
  import Role.Misc
  defstruct role_id: nil, last_save_time: nil, status: 0, last_msg_time: nil

  # @status_init 0
  @status_online 1
  @status_offline 2

  @save_interval 5
  @loop_interval 1000

  ## =====API====
  # def start(role_id) do
  #   DynamicSupervisor.start_child(
  #     Role.Sup,
  #     {__MODULE__, role_id}
  #   )
  # end

  def pid(role_id) do
    :global.whereis_name(name(role_id))
  end

  def exit(role_id) do
    cast(role_id, :exit)
  end

  def client_msg(role_id, msg) do
    cast(role_id, {:client_msg, msg})
  end

  def reconnect(role_id) do
    cast(role_id, :reconnect)
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

  def sid() do
    Process.get(:sid)
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
    Logger.debug("role.svr [#{role_id}]  start")
    Process.put(:role_id, role_id)
    Process.put(:sid, sid(role_id))
    :pg.join(__MODULE__, self())
    Role.load_data()
    hook(:init)
    Process.send_after(self(), :secondloop, @loop_interval)
    now = Util.unixtime()
    last_save_time = now
    last_msg_time = now
    status = @status_online
    {:ok, ~M{%Role.Svr role_id,last_save_time,status,last_msg_time}}
  end

  @impl true
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
    try do
      Role.save_all()
      {:stop, :normal, state}
    rescue
      err ->
        Logger.warning("safe save data error: #{inspect(err)}, retry later..")
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
    with {:ok, msg} <- PB.decode(data) do
      mod = msg |> Map.get(:__struct__) |> PB.mod()
      mod.h(msg)
    else
      _ ->
        Logger.warning("client msg decode error")
    end

    last_msg_time = Util.unixtime()
    {:noreply, ~M{%Role.Svr state | last_msg_time}}
  end

  def handle_cast(:reconnect, ~M{role_id} = state) do
    Process.put(:sid, Role.Misc.sid(role_id))
    status = @status_online
    {:noreply, ~M{state|status}}
  end

  def handle_cast(:exit, state) do
    Logger.debug("exit role svr #{state.role_id} ")
    hook(:on_terminate)
    Process.send(self(), :safe_stop, [:nosuspend])
    {:noreply, state}
  end

  def handle_cast(:offline, state) do
    Logger.debug("role offline")
    hook(:on_offline)
    status = @status_offline
    {:noreply, ~M{%Role.Svr state|status}}
  end

  @impl true
  def handle_call({:apply, mod, f, args}, _from, state) do
    reply = :erlang.apply(mod, f, args)
    {:reply, reply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Role.save_all()
    :ok
  end

  @impl true
  def code_change(old_vsn, state, extra) do
    for mod <- extra, mod != __MODULE__ do
      apply(mod, :code_change, [old_vsn])
    end

    {:ok, state}
  end

  defp hook(f, args \\ []) do
    args_len = length(args)

    for mod <- PB.modules() do
      try do
        if function_exported?(mod, f, args_len) do
          apply(mod, f, args)
        else
          true
        end
      catch
        kind, reason ->
          Logger.error("#{mod} [#{f}] error !! #{kind} , #{reason}, #{inspect(__STACKTRACE__)} ")
          false
      end
    end
  end

  defp check_save(~M{%Role.Svr last_save_time} = state, now) do
    if now - last_save_time >= @save_interval do
      hook(:save)
      ~M{state | last_save_time: now }
    else
      state
    end
  end

  defp check_down(~M{%Role.Svr last_msg_time,status} = state, now) do
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
