defmodule Mod.Chat do
  defstruct channels: %{}, last_chat_time: nil
  use Role.Mod

  def h(state, ~M{%Chat.Chat2S channel,content,time}) do
    %Chat.Chat2C{content: "fuckofffgdfgdfgdfasddsaxcvx", channel: 2, time: Util.unixtime()}
    |> Role.Misc.broad_cast_all()

    last_chat_time = Util.unixtime()
    {:ok, ~M{state| last_chat_time}}
  end
end
