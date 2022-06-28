defmodule Reloader do
  def update_all() do
    :code.modified_modules()
    |> update()
  end

  defp mod_type(Role.Svr) do
    :role
  end

  defp mod_type(mod) do
    if Enum.member?(PB.modules(), mod) do
      :role
    else
      :other
    end
  end

  def update(mods) do
    group = Enum.group_by(mods, &mod_type/1)
    (group[:other] || []) |> Enum.each(&update_mod/1)
    (group[:role] || []) |> update_role_mods()
  end

  defp update_role_mods([]), do: :ok

  defp update_role_mods([mod | mods]) do
    pids = :pg.get_local_members(Role.Svr)
    pids |> Enum.each(&:sys.suspend(&1))
    :code.purge(mod)
    :code.load_file(mod)

    pids
    |> Enum.each(fn pid ->
      :sys.change_code(pid, mod, '0.1.0', [mod], 10000)
    end)

    pids |> Enum.each(&:sys.resume(&1))
    :code.soft_purge(mod)
    update_role_mods(mods)
  end

  defp update_mod(mod) do
    :code.purge(mod)
    :code.load_file(mod)
  end
end
