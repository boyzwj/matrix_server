defmodule PBClass do
  use Common

  def template(constdef, type2id, id2parser) do
    """
    using System;
    using Google.Protobuf;
    using System.Collections.Generic;
    namespace Script.Network
    {
        public class PB
        {
    #{constdef}

            private static var _dic_id = new Dictionary<Type, ushort>()
            {
    #{type2id}
            };

            private static var _dic_parser = new Dictionary<ushort, MessageParser>()
            {
    #{id2parser}
            };
            public static ushort GetCmdID(IMessage obj)
            {
              ushort cmd = 0;
              Type type = obj.GetType();
              if (_dic_id.TryGetValue(type, out cmd))
              {
                return cmd;
              }

              return cmd;
            }

            public static MessageParser GetParser(ushort id)
            {
              MessageParser parser;
              if (_dic_parser.TryGetValue(id, out parser))
              {
                return parser;
              }

              return parser;
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

    "\t\t\t{typeof(#{proto}), #{const_name}},\n"
  end

  defp gen_id2parser(~M{_id,_package,proto}) do
    const_name = String.replace(proto, ".", "")
    "\t\t\t{#{const_name},  #{proto}.Parser},\n"
  end
end
