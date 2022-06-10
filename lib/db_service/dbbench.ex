defmodule DBBench do
  defp do_set(pid, id) do
    spawn(fn ->
      Redis.hset(id, Mod.System, %{a: 1, b: 2, c: 3, d: "fsdfsdfsfsfs"})
      Process.send(pid, :ok, [:nosuspend])
    end)
  end

  defp do_get(pid, id) do
    spawn(fn ->
      Redis.hget(id, Mod.System)
      Process.send(pid, :ok, [:nosuspend])
    end)
  end

  defp pend(0), do: :ok

  defp pend(n) do
    receive do
      :ok ->
        pend(n - 1)
        # code
    end
  end

  def set(n) do
    1..n
    |> Enum.each(fn id -> do_set(self(), id) end)

    pend(n)
  end

  def get(n) do
    1..n
    |> Enum.each(fn id -> do_get(self(), id) end)

    pend(n)
  end

  def run() do
    Benchee.run(
      %{
        "write" => fn ->
          set(10000)
        end,
        "read" => fn ->
          get(10000)
        end
      },
      time: 10,
      memory_time: 0
    )
  end
end
