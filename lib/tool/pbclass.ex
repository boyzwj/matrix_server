defmodule PBClass do
  use Common

  def template(constdef, type2id, id2parser) do
    """
    using System;
    using Google.Protobuf;
    namespace Script.Network
    {
        public class PB
        {
    #{constdef}

            public static ushort GetCmdID(IMessage obj)
            {
                Type type = obj.GetType();
      #{type2id}
                return 0;
            }

            public static MessageParser GetParser(ushort id)
            {
    #{id2parser}
                return null;
            }
        }
    }
    """
  end

  def create() do
    File.write!("#{:code.priv_dir(:matrix_server)}/static/PB.cs", content(), [:write])
  end

  def content() do
    constdef = ""
    type2id = ""
    id2parser = ""

    {constdef, type2id, id2parser} =
      PB.PBID.proto_ids()
      |> create(constdef, type2id, id2parser)

    template(constdef, type2id, id2parser)
  end

  defp create([], constdef, type2id, id2parser) do
    {constdef, type2id, id2parser}
  end

  defp create([m | t], constdef, type2id, id2parser) do
    constdef = constdef <> gen_constdef(m)
    type2id = type2id <> gen_type2id(m)
    id2parser = id2parser <> gen_id2parser(m)
    create(t, constdef, type2id, id2parser)
  end

  defp gen_constdef(~M{id,_package,proto}) do
    const_name = String.replace(proto, ".", "")
    "\t\tpublic const ushort #{const_name} = #{id};\n"
  end

  defp gen_type2id(~M{_id,_package,proto}) do
    const_name = String.replace(proto, ".", "")

    """
    \t\t\tif (type == typeof(#{proto}))
    \t\t\t{
    \t\t\t    return #{const_name};
    \t\t\t}
    """
  end

  defp gen_id2parser(~M{_id,_package,proto}) do
    const_name = String.replace(proto, ".", "")

    """
    \t\t\tif (id == #{const_name})
    \t\t\t{
    \t\t\t    return #{proto}.Parser;
    \t\t\t}
    """
  end
end
