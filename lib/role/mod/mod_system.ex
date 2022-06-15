defmodule Mod.System do
  defstruct id: nil, last_ping: nil, update_at: nil
  use Role.Mod

  def h(state, %System.Ping2S{}) do
    last_ping = Util.unixtime()
    ~M{state| last_ping}
  end
end
