defmodule DB do
  import PipeTo

  def save(data) do
    Role.RoleSvr.role_id()
    |> Role.Misc.role_db_key()
    |> DB.Redis.hset(data.__struct__, data_to_json(data))
  end

  def load(mod) do
    with data when data != nil <-
           Role.RoleSvr.role_id()
           |> Role.Misc.role_db_key()
           |> DB.Redis.hget(mod) do
      data
      |> Jason.decode!(keys: :atoms)
      |> Map.to_list()
      ~> Kernel.struct(mod, _)
    else
      _ ->
        Kernel.struct(mod)
    end
  end

  defp data_to_json(data) do
    data
    |> Map.from_struct()
    |> Jason.encode!()
  end
end
