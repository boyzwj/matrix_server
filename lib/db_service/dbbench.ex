defmodule DBBench do
  def run() do
    Benchee.run(
      %{
        "dirty_write" => fn ->
          1..10000 |> Enum.each(&:mnesia.dirty_write({Role.Mod.System, &1, 100_000, 100_000}))
        end,
        "tranc_write" => fn ->
          1..10000
          |> Enum.each(
            &:mnesia.transaction(fn ->
              :mnesia.write({Role.Mod.System, &1, 100_000, 100_000})
            end)
          )
        end
      },
      time: 10,
      memory_time: 2
    )
  end
end
