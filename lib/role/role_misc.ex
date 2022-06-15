defmodule Role.Misc do
  def sid(role_id) do
    GateWay.Session.name(role_id)
    |> :global.whereis_name()
  end

  def online(role_id) do
    role_id
    |> sid()
    |> Process.alive?()
  end

  def broad_cast_all(msg) do
    if (pids = :pg.get_members(GateWay.Session)) != [] do
      data = PB.encode!(msg)
      Manifold.send(pids, {:send_buff, data})
    end
  end

  def send_to(role_id, msg) when is_integer(role_id) do
    sid = sid(role_id)
    sid && Process.send(sid, {:send_buff, PB.encode!(msg)}, [:nosuspend])
  end

  def send_to(sid, msg) when is_pid(sid) do
    sid && Process.send(sid, {:send_buff, PB.encode!(msg)}, [:nosuspend])
  end
end
