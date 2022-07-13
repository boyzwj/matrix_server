defmodule Role.Mod.Role do
  defstruct account: "", role_name: "", gender: 1, head_id: 1, avatar_id: 1, rank: 0
  use Role.Mod
  use Memoize

  def h(state, ~M{%Role.Info2S }) do
    with ~M{%M } = data <- state do
      role_info = to_common(data)
      ~M{%Role.Info2C role_info} |> sd()
    else
      _ ->
        :ignore
    end
  end

  def h(_state, ~M{%Role.OtherInfo2S requests}) do
    infos =
      for ~M{role_id,timestamp} <- requests do
        {cachetime, role_info} = role_info(role_id)

        if timestamp < cachetime do
          %Role.InfoReply{role_id: role_id, timestamp: cachetime, role_info: role_info}
        else
          %Role.InfoReply{role_id: role_id, timestamp: timestamp}
        end
      end

    ~M{%Role.OtherInfo2C  infos} |> sd()
    :ok
  end

  defp on_after_save(false), do: false

  defp on_after_save(true) do
    Role.Manager.clear_cache(__MODULE__, :role_info, [role_id()])
    true
  end

  defmemo role_info(role_id), expires_in: 86_400_000 do
    data = load(role_id)
    role_info = data && to_common(data)
    cachetime = Util.unixtime()
    {cachetime, role_info}
  end

  def common_data() do
    get_data() |> to_common()
  end

  defp to_common(data) do
    data = Map.from_struct(data)
    data = struct(Common.RoleInfo, data)
    ~M{data | role_id()}
  end
end
