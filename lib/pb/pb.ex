defmodule PB do
  require Logger
  use PipeTo.Override

  use Protox,
    files:
      File.ls!("./proto")
      |> Enum.filter(&String.ends_with?(&1, ".proto"))
      |> Enum.map(&"./proto/#{&1}")

  proto_ids = Tool.Pbid.proto_ids("./proto")

  pkgs =
    for %{id: _id, proto: proto} <- proto_ids, m = Module.concat([proto]), into: MapSet.new() do
      [_namespace, pkg, _method] = String.split(proto, ".", parts: 3)
      mod = Module.concat(["Elixir", "Role", "Mod", pkg])

      def mod(unquote(m)) do
        unquote(mod)
      end

      mod
    end
    |> Enum.to_list()

  def modules() do
    unquote(pkgs)
  end

  for %{id: id, proto: proto} <- proto_ids, m = Module.concat([proto]) do
    def proto_id(unquote(m)) do
      unquote(id)
    end
  end

  for %{id: id, proto: proto} <- proto_ids, m = Module.concat([proto]) do
    [_namespace, pkg, _method] = String.split(proto, ".", parts: 3)
    handler = Module.concat(["PP", pkg])

    def proto_module(unquote(id)) do
      [unquote(m), unquote(handler)]
    end
  end

  def proto_module(id) do
    Logger.warn("unknow proto_id : #{id}")
    :error
  end

  def decode(<<proto_id::16-little, data::binary>>) do
    with [m, _] <- proto_module(proto_id) do
      m.decode(data)
    else
      _ ->
        {:error, :invalid_message}
    end
  end

  def decode!(<<proto_id::16-little, data::binary>>) do
    [m, _] = proto_module(proto_id)
    m.decode!(data)
  end

  def encode(%{__struct__: m} = data) do
    case m.encode(data) do
      {:ok, d} ->
        {:ok, [<<proto_id(m)::16-little>> | d]}

      {:error, _exception} ->
        {:error, :invalid_message}
    end
  end

  def encode!(%{__struct__: m} = data) do
    d = m.encode!(data)
    [<<proto_id(m)::16-little>> | d]
  end
end
