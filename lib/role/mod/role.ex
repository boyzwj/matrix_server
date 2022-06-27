defmodule Role.Mod.Role do
  defstruct role_name: "", head_id: nil, avatar_id: nil
  use Role.Mod

  def h(state, ~M{%Role.Info2S }) do
    with ~M{role_name,head_id,avatar_id} <- state do
      role_info = ~M{%Common.RoleInfo role_id(), role_name,head_id,avatar_id}
      ~M{%Role.Info2C role_info} |> sd()
    else
      _ ->
        :ignore
    end
  end
end
