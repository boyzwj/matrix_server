defmodule Robot.Handler do
  use Common

  def h(state, msg) do
    Logger.warning("unhandle msg: #{inspect(msg)}")
    state
  end
end
