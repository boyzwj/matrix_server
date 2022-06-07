defmodule Mod.System do
  use Role.Mod,
    attributes: [:id, :last_ping, :update_at],
    type: :set

  defp init(data) do
    IO.inspect({:init, data})
    set_data(data)
  end

  def h(state, %System.Ping2S{}) do
    last_ping = Util.unixtime()
    ~M{state| last_ping}
  end
end
