defmodule Role.Misc do
  def role_pid_name(role_id) do
    "R_#{role_id}"
    |> String.to_atom()
  end

  def sid_name(role_id) do
    "S_#{role_id}"
    |> String.to_atom()
  end

  def reg_sid(role_id, sid) do
    name = sid_name(role_id)
    if Process.whereis(name), do: Process.unregister(name)
    Process.register(sid, name)
  end

  def role_sid(role_id) do
    sid_name(role_id) |> Process.whereis()
  end

  def role_pid(role_id) do
    role_pid_name(role_id) |> Process.whereis()
  end

  def online(role_id) do
    role_pid(role_id) |> alive()
  end

  defp alive(nil), do: false

  defp alive(pid) do
    Process.alive?(pid)
  end

  defp reg_rid(role_id, pid) do
    name = role_pid_name(role_id)
    if Process.whereis(name), do: Process.unregister(name)
    Process.register(pid, name)
  end
end
