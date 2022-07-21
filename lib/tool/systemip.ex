defmodule Systemip do
  def private_ipv4() do
    {:ok, addrs} = :inet.getif()

    filtered =
      Enum.filter(
        addrs,
        fn address ->
          ip = elem(address, 0)
          is_private_ipv4(ip)
        end
      )

    elem(hd(filtered), 0)
  end

  defp is_private_ipv4(ip) do
    case ip do
      {10, _x, _y, _z} ->
        true

      {192, 168, _x, _y} ->
        true

      {172, _, _x, _y} ->
        true

      _ ->
        false
    end
  end
end
