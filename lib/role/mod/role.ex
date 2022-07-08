defmodule Role.Mod.Role do
  defstruct account: "", role_name: "", gender: 1, head_id: 1, avatar_id: 1, rank: 0
  use Role.Mod

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
    now = Util.unixtime()

    infos =
      for ~M{role_id,timestamp} <- requests do
        if ttl(role_id) > timestamp do
          role_info = load(role_id) |> to_common()
          %Role.InfoReply{role_id: role_id, timestamp: now, role_info: role_info}
        else
          %Role.InfoReply{role_id: role_id, timestamp: timestamp}
        end
      end

    ~M{%Role.OtherInfo2C  infos} |> sd()
    :ok
  end

  defp on_after_save(false), do: false

  defp on_after_save(true) do
    Redis.hset("TTL:#{role_id()}", __MODULE__, Util.unixtime())
  end

  def ttl(role_id) do
    data = Redis.hget("TTL:#{role_id}", __MODULE__)
    data && Jason.decode!(data)
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
