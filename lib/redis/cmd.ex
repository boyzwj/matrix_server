defmodule Redis.Cmd do
  use Common

  def handle(conn, cmd, args) do
    args = args |> Enum.map(&parse(&1))
    Redix.command!(conn, [cmd | args])
  end

  def clear(conn) do
    Redix.command!(conn, ["FLUSHALL"])
  end

  defp parse(value) when is_map(value) do
    Jason.encode!(value)
  end

  defp parse(value), do: value
end
