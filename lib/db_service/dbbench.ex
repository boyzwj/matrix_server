defmodule DBBench do
  def run() do
    Benchee.run(
      %{
        "dirty_read" => fn ->
          1..10000 |> Enum.each(&DBA.dirty_read(Role.Mod.System, &1))
        end,
        "dirty_write" => fn ->
          1..10000
          |> Enum.each(
            &DBA.dirty_write(%Role.Mod.System{id: &1, update_at: 10000, last_ping: 10000})
          )
        end
      },
      time: 10,
      memory_time: 0
    )
  end
end
