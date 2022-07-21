defmodule Dc.Handler do
  use Common

  def h(state, %Dc.HeartBeat2S{}) do
    Logger.debug("receive heart")
    state
  end
end
