defmodule Mod.Chat do
  defstruct channels: %{}, last_chat_time: nil
  use Role.Mod

  def h(state, ~M{%Chat.Chat2S channel,content}) do
    IO.inspect("chat 2s #{content}")
    role_id = RoleSvr.role_id()

    %Chat.Chat2C{role_id: role_id, content: content, channel: channel, time: Util.unixtime()}
    |> Role.Misc.broad_cast_all()

    last_chat_time = Util.unixtime()
    {:ok, ~M{state| last_chat_time}}
  end
end
