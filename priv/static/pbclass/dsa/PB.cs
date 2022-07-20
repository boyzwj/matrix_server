using System;
using Google.Protobuf;
using System.Collections.Generic;
namespace Script.Network
{
    public class PB
    {
        public const ushort PbmDsaPlayerQuit2S = 54870;
        public const ushort PbmDsaPlayerState2S = 16081;
        public const ushort PbmDsaHeartbeat2S = 25101;
        public const ushort PbmDsaRoleReady2S = 56216;
        public const ushort PbmDsaRoleInfo2C = 2538;
        public const ushort PbmDsaBattleInfo2C = 46785;
        public const ushort PbmDsaBattleInfo2S = 18274;
        public const ushort PbmDsaStart2S = 38063;


        private static Dictionary<Type, ushort> _dic_id = new Dictionary<Type, ushort>()
        {
            {typeof(Pbm.Dsa.PlayerQuit2S), PbmDsaPlayerQuit2S},
            {typeof(Pbm.Dsa.PlayerState2S), PbmDsaPlayerState2S},
            {typeof(Pbm.Dsa.Heartbeat2S), PbmDsaHeartbeat2S},
            {typeof(Pbm.Dsa.RoleReady2S), PbmDsaRoleReady2S},
            {typeof(Pbm.Dsa.RoleInfo2C), PbmDsaRoleInfo2C},
            {typeof(Pbm.Dsa.BattleInfo2C), PbmDsaBattleInfo2C},
            {typeof(Pbm.Dsa.BattleInfo2S), PbmDsaBattleInfo2S},
            {typeof(Pbm.Dsa.Start2S), PbmDsaStart2S},

        };

        private static Dictionary<ushort, MessageParser> _dic_parser = new Dictionary<ushort, MessageParser>()
        {
            {PbmDsaPlayerQuit2S,  Pbm.Dsa.PlayerQuit2S.Parser},
            {PbmDsaPlayerState2S,  Pbm.Dsa.PlayerState2S.Parser},
            {PbmDsaHeartbeat2S,  Pbm.Dsa.Heartbeat2S.Parser},
            {PbmDsaRoleReady2S,  Pbm.Dsa.RoleReady2S.Parser},
            {PbmDsaRoleInfo2C,  Pbm.Dsa.RoleInfo2C.Parser},
            {PbmDsaBattleInfo2C,  Pbm.Dsa.BattleInfo2C.Parser},
            {PbmDsaBattleInfo2S,  Pbm.Dsa.BattleInfo2S.Parser},
            {PbmDsaStart2S,  Pbm.Dsa.Start2S.Parser},

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
