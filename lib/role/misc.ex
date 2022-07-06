defmodule Role.Misc do
  def dbkey() do
    Role.Svr.role_id() |> dbkey()
  end

  @doc """
  获取本进程角色ID
  """
  def role_id() do
    Process.get(:role_id)
  end

  def dbkey(role_id) do
    "role:#{role_id}"
  end

  def sid(role_id) do
    GateWay.Session.name(role_id)
    |> :global.whereis_name()
  end

  def online?(role_id) do
    role_id
    |> sid()
    |> Process.alive?()
  end

  def broad_cast_all(msg) do
    if (pids = :pg.get_members(GateWay.Session)) != [] do
      data = PB.encode!(msg)
      Manifold.send(pids, {:send_buff, data})
    else
      :ok
    end
  end

  def send_to(_msg, nil), do: :ignore

  def send_to(msg, role_id) when is_integer(role_id) do
    sid = sid(role_id)
    sid && Process.send(sid, {:send_buff, PB.encode!(msg)}, [:nosuspend])
    :ok
  end

  def send_to(msg, sid) when is_pid(sid) do
    sid && Process.send(sid, {:send_buff, PB.encode!(msg)}, [:nosuspend])
    :ok
  end

  @doc """
  进程内协议发送接口
  """
  def sd(msg) do
    sid = Process.get(:sid)
    send_to(msg, sid)
  end

  @doc """
  进程内错误码发送接口
  """
  def sd_err(error_code, error_msg \\ nil) do
    sid = Process.get(:sid)
    msg = %System.Error2C{error_code: error_code, error_msg: error_msg}
    send_to(msg, sid)
  end
end
