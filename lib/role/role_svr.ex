defmodule Role.RoleSvr do
  use GenServer
  use Common
  @save_interval 30
  @loop_interval 1000

  def start(args, options \\ []) do
    GenServer.start(__MODULE__, args, options)
  end

  @impl true
  def init(~M{role_id,sid} = args) do
    Process.put(:sid, sid)
    Process.put(:role_id, role_id)
    Role.Misc.reg_sid(role_id, sid)
    Process.send_after(self(), :secondloop, @loop_interval)
    Process.send(self(), :init, [:nosuspend])
    {:ok, args}
  end

  def handle_info(:init, state) do
    hook(:init)
    {:noreply, state}
  end

  def handle_info(:secondloop, state) do
    hook(:secondloop)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
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
