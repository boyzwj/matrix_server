defmodule Role do
  use Common

  def load_data() do
    Role.Misc.dbkey()
    |> Redis.hgetall()
    |> do_load()
  end

  defp do_load([]), do: :ok

  defp do_load([k, v | tail]) do
    mod = String.to_atom(k)
    data = v && Poison.decode!(v, as: mod.__struct__)
    mod.set_data(data)
    do_load(tail)
  end

  def save_all() do
    array =
      PB.modules()
      |> Enum.reduce([], fn mod, acc ->
        if mod.dirty?() do
          data = mod.get_data() |> Map.from_struct() |> Jason.encode!()
          [mod, data | acc]
        else
          acc
        end
      end)

    Redis.hset_array(Role.Misc.dbkey(), array)
  end
end
