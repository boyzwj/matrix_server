defmodule Robot.Handler do
  use Common

  def h(state, %Chat.Chat2C{content: content}) do
    Logger.debug("收到聊天信息: " <> content)
    state
  end

  def h(state, msg) do
    Logger.warning("robot: #{state.role_id},unhandle msg: #{inspect(msg)}")
    state
  end
end
