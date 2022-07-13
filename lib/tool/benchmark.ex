defmodule Tool.Benchmark do
  def test() do
    Benchee.run(%{
      "role_info" => fn -> Role.Mod.Role.role_info(100_000_001) end,
      "role_info1" => fn -> Role.Mod.Role.role_info1(100_000_001) end
    })
  end
end
