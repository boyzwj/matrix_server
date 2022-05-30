defmodule Role.RoleSvr do
  use GenServer
  use Common
  @save_interval 30
  @loop_interval 1000

  ## =====API====
  def start(args, options \\ []) do
    GenServer.start(__MODULE__, args, options)
  end

  def client_msg(player_pid, msg) do
    GenServer.cast(player_pid, {:client_msg, msg})
  end

  def offline(player_pid) do
    GenServer.cast(player_pid, :offline)
  end

  def role_id() do
    Process.get(:role_id)
  end

  ## ===CALLBACK====
  @impl true
  def init(~M{role_id,sid} = args) do
    Process.put(:sid, sid)
    Process.put(:role_id, role_id)
    Role.Misc.reg_sid(role_id, sid)
    Process.send_after(self(), :secondloop, @loop_interval)
    Process.send(self(), :init, [:nosuspend])
    {:ok, args}
  end

  @impl true
  def handle_info(:init, state) do
    hook(:init)
    {:noreply, state}
  end

  def handle_info(:secondloop, state) do
    hook(:secondloop)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:client_msg, msg}, state) do
    mod = msg |> Map.get(:__struct__) |> PB.PP.mod()
    mod.h(msg)
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    hook(:terminate)
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
      end
    end
  end
end
