defmodule Tool.Benchmark do
  def test() do
    Process.put(:sid, :global.whereis_name(:sid_10))
    role_id = 10

    Benchee.run(%{
      "dict" => fn -> Process.get(:sid) end,
      "global1" => fn -> :global.whereis_name(:"sid_#{role_id}") end,
      "global2" => fn -> :global.whereis_name(:sid_10) end
    })
  end
end
