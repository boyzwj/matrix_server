defmodule Mod.Chat do
  defstruct channels: %{}
  use Role.Mod

  def h(state, ~M{%Chat.Chat2S channel,content,time}) do
    %Chat.Chat2C{content: "fuckofffgdfgdfgdfasddsaxcvx", channel: 2, time: Util.unixtime()}
    |> Role.Misc.broad_cast_all()

    state
  end
end
