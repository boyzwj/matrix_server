defmodule Util do
  @moduledoc false
  require Logger

  def unixtime do
    System.os_time(:second)
  end

  def longunixtime do
    System.os_time(:millisecond)
  end

  def md5(value) do
    :crypto.hash(:md5, value)
  end

  def rand(min, max) when max > min do
    m = min - 1
    :rand.uniform(max - m) + m
  end

  def rand(max, min) do
    m = min - 1
    :rand.uniform(max - m) + m
  end

  def rand_list(l) do
    l = :erlang.list_to_tuple(l)
    len = :erlang.tuple_size(l)

    if len > 0 do
      rand(1, len) |> :erlang.element(l)
    else
      nil
    end
  end

  def shuffle([]) do
    []
  end

  def shuffle([_ | _] = list) do
    list
    |> :erlang.list_to_tuple()
    |> shuffle()
  end

  def shuffle({}), do: []

  def shuffle(t = {_}), do: :erlang.tuple_to_list(t)
  def shuffle(t), do: shuffle(1, t, :erlang.size(t))

  defp shuffle(len, t, len), do: :erlang.tuple_to_list(t)

  defp shuffle(cur, t, len) do
    s = cur + rand(1, len - cur)
    t2 = swap_element(t, cur, s)
    shuffle(cur + 1, t2, len)
  end

  defp swap_element(t, n, n), do: t

  defp swap_element(t, n1, n2) do
    e1 = :erlang.element(n1, t)
    e2 = :erlang.element(n2, t)
    t1 = :erlang.setelement(n1, t, e2)
    :erlang.setelement(n2, t1, e1)
  end
end
