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

  def common_data() do
    get_data() |> to_common()
  end

  defp to_common(data) do
    data = Map.from_struct(data)
    data = struct(Common.RoleInfo, data)
    ~M{data | role_id()}
  end
end
