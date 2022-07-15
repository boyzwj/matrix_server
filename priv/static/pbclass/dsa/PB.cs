using System;
using Google.Protobuf;
using System.Collections.Generic;
namespace Script.Network
{
    public class PB
    {
        public const ushort DsaPlayerQuit2S = 31139;
        public const ushort DsaPlayerState2S = 49706;
        public const ushort DsaHeartbeat2S = 831;
        public const ushort DsaRoleReady2S = 12563;
        public const ushort DsaRoleInfo2C = 18767;
        public const ushort DsaBattleInfo2C = 21980;
        public const ushort DsaBattleInfo2S = 12468;
        public const ushort DsaStart2S = 18179;


        private static Dictionary<Type, ushort> _dic_id = new Dictionary<Type, ushort>()
        {
            {typeof(Dsa.PlayerQuit2S), DsaPlayerQuit2S},
            {typeof(Dsa.PlayerState2S), DsaPlayerState2S},
            {typeof(Dsa.Heartbeat2S), DsaHeartbeat2S},
            {typeof(Dsa.RoleReady2S), DsaRoleReady2S},
            {typeof(Dsa.RoleInfo2C), DsaRoleInfo2C},
            {typeof(Dsa.BattleInfo2C), DsaBattleInfo2C},
            {typeof(Dsa.BattleInfo2S), DsaBattleInfo2S},
            {typeof(Dsa.Start2S), DsaStart2S},

        };

        private static Dictionary<ushort, MessageParser> _dic_parser = new Dictionary<ushort, MessageParser>()
        {
            {DsaPlayerQuit2S,  Dsa.PlayerQuit2S.Parser},
            {DsaPlayerState2S,  Dsa.PlayerState2S.Parser},
            {DsaHeartbeat2S,  Dsa.Heartbeat2S.Parser},
            {DsaRoleReady2S,  Dsa.RoleReady2S.Parser},
            {DsaRoleInfo2C,  Dsa.RoleInfo2C.Parser},
            {DsaBattleInfo2C,  Dsa.BattleInfo2C.Parser},
            {DsaBattleInfo2S,  Dsa.BattleInfo2S.Parser},
            {DsaStart2S,  Dsa.Start2S.Parser},

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
