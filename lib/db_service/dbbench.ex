defmodule DBBench do
  def run() do
    Benchee.run(
      %{
        "read" => fn ->
          1..10000
          |> Enum.each(&DBA.read(Service.Session, &1))
        end,
        "write" => fn ->
          1..10000
          |> Enum.each(&DBA.write(%Service.Session{id: &1, role_id: &1}))
        end
      },
      time: 10,
      memory_time: 0
    )
  end
end
