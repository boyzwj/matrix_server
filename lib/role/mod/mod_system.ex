defmodule Mod.System do
  use Role.Mod,
    attributes: [:id, :last_ping, :update_at],
    type: :set

  def h(state, %System.Ping2S{}) do
    Logger.debug("receive ping2s")
    last_ping = Util.unixtime()
    ~M{state| last_ping}
  end
end
