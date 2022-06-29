defmodule PBLua do
  use Common

  @doc """
  创建协议LUA定义文件
  """
  def create() do
    pkgs =
      for mod <- PB.modules() do
        "#{mod}"
        |> String.split(".")
        |> List.last()
        |> String.downcase()
        |> (&"#{&1}").()
      end
      |> Enum.join(",\n\t")

    pt =
      for ~M{id,proto} <- PB.PBID.proto_ids() do
        proto
        |> String.split(".")
        |> Enum.map(&String.downcase(&1))
        |> Enum.join("_")
        |> (&"#{&1} = #{id}").()
      end
      |> Enum.join(",\n\t")

    msg_names =
      for ~M{id,proto} <- PB.PBID.proto_ids() do
        proto
        |> downcase_first()
        |> (&"[#{id}] = [[#{&1}]]").()
      end
      |> Enum.join(",\n\t")

    content = template(pt, msg_names, pkgs)
    File.write!("./proto/PT.lua", content, [:write])
  end

  defp template(constdef, type2id, pkgs) do
    """
    PT = {
      #{constdef}
    }
    PT_NAMES = {
      #{type2id}
    }
    PT_PKGS = {
      #{pkgs}
    }
    """
  end

  defp downcase_first(<<first::utf8, rest::binary>>) do
    String.downcase(<<first::utf8>>) <> rest
  end
end
