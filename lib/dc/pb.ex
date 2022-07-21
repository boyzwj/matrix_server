defmodule Dc.Pb do
  use Protox,
    files:
      File.ls!("#{:code.priv_dir(:matrix_server)}/proto/")
      |> Enum.filter(&String.ends_with?(&1, ".proto"))
      |> Enum.map(&"#{:code.priv_dir(:matrix_server)}/proto/#{&1}")

  proto_ids = Tool.Pbid.proto_ids("#{:code.priv_dir(:matrix_server)}/proto/")

  for %{id: id, proto: proto} <- proto_ids, m = Module.concat([proto]) do
    def proto_id(unquote(m)) do
      unquote(id)
    end
  end

  for %{id: id, proto: proto} <- proto_ids, m = Module.concat([proto]) do
    def proto_module(unquote(id)) do
      unquote(m)
    end
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

  def decode(<<proto_id::16-little, data::binary>>) do
    with m <- proto_module(proto_id) do
      m.decode(data)
    else
      _ ->
        {:error, :invalid_message}
    end
  end

  def decode!(<<proto_id::16-little, data::binary>>) do
    m = proto_module(proto_id)
    m.decode!(data)
  end
end
