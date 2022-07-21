using System;
using Google.Protobuf;
using System.Collections.Generic;
namespace Script.Network
{
    public class PB
    {
        public const ushort PbmRoleSetName2C = 32470;
        public const ushort PbmRoleSetName2S = 47496;
        public const ushort PbmRoleOtherInfo2C = 54225;
        public const ushort PbmRoleOtherInfo2S = 45068;
        public const ushort PbmRoleInfo2C = 24773;
        public const ushort PbmRoleInfo2S = 53968;
        public const ushort PbmDsaPlayerQuit2S = 54870;
        public const ushort PbmDsaPlayerState2S = 16081;
        public const ushort PbmDsaHeartbeat2S = 25101;
        public const ushort PbmDsaRoleReady2S = 56216;
        public const ushort PbmDsaRoleInfo2C = 2538;
        public const ushort PbmDsaBattleInfo2C = 46785;
        public const ushort PbmDsaBattleInfo2S = 18274;
        public const ushort PbmDsaStart2S = 38063;
        public const ushort PbmRoomStartGame2C = 37626;
        public const ushort PbmRoomStartGame2S = 57425;
        public const ushort PbmRoomExit2C = 54014;
        public const ushort PbmRoomExit2S = 44298;
        public const ushort PbmRoomChangePosResult2C = 62327;
        public const ushort PbmRoomChangePosRefuse2C = 50634;
        public const ushort PbmRoomChangePosReply2S = 11058;
        public const ushort PbmRoomChangePosReq2C = 65121;
        public const ushort PbmRoomChangePos2S = 33932;
        public const ushort PbmRoomKick2C = 31404;
        public const ushort PbmRoomKick2S = 18157;
        public const ushort PbmRoomJoin2C = 25419;
        public const ushort PbmRoomJoin2S = 2930;
        public const ushort PbmRoomQuickJoin2S = 27976;
        public const ushort PbmRoomSetRoomMap2C = 36269;
        public const ushort PbmRoomSetRoomMap2S = 17982;
        public const ushort PbmRoomCreate2C = 33697;
        public const ushort PbmRoomCreate2S = 50392;
        public const ushort PbmRoomList2C = 21422;
        public const ushort PbmRoomList2S = 57063;
        public const ushort PbmRoomSetFilter2C = 25230;
        public const ushort PbmRoomSetFilter2S = 61735;
        public const ushort PbmRoomUpdate2C = 36893;
        public const ushort PbmRoomInfo2C = 4701;
        public const ushort PbmRoomInfo2S = 64797;
        public const ushort PbmChatChat2C = 15478;
        public const ushort PbmChatChat2S = 16944;
        public const ushort PbmSystemError2C = 7151;
        public const ushort PbmTeamBeginMatch2S = 49434;
        public const ushort PbmTeamExit2C = 53247;
        public const ushort PbmTeamExit2S = 13314;
        public const ushort PbmTeamJoin2C = 38148;
        public const ushort PbmTeamInviteReply2C = 18418;
        public const ushort PbmTeamInviteReply2S = 14489;
        public const ushort PbmTeamInviteRequest2C = 50589;
        public const ushort PbmTeamInvite2C = 12391;
        public const ushort PbmTeamInvite2S = 34614;
        public const ushort PbmTeamCreate2C = 54374;
        public const ushort PbmTeamCreate2S = 7059;
        public const ushort PbmTeamInfo2C = 22011;
        public const ushort PbmTeamInfo2S = 28179;


        private static Dictionary<Type, ushort> _dic_id = new Dictionary<Type, ushort>()
        {
            {typeof(Pbm.Role.SetName2C), PbmRoleSetName2C},
            {typeof(Pbm.Role.SetName2S), PbmRoleSetName2S},
            {typeof(Pbm.Role.OtherInfo2C), PbmRoleOtherInfo2C},
            {typeof(Pbm.Role.OtherInfo2S), PbmRoleOtherInfo2S},
            {typeof(Pbm.Role.Info2C), PbmRoleInfo2C},
            {typeof(Pbm.Role.Info2S), PbmRoleInfo2S},
            {typeof(Pbm.Dsa.PlayerQuit2S), PbmDsaPlayerQuit2S},
            {typeof(Pbm.Dsa.PlayerState2S), PbmDsaPlayerState2S},
            {typeof(Pbm.Dsa.Heartbeat2S), PbmDsaHeartbeat2S},
            {typeof(Pbm.Dsa.RoleReady2S), PbmDsaRoleReady2S},
            {typeof(Pbm.Dsa.RoleInfo2C), PbmDsaRoleInfo2C},
            {typeof(Pbm.Dsa.BattleInfo2C), PbmDsaBattleInfo2C},
            {typeof(Pbm.Dsa.BattleInfo2S), PbmDsaBattleInfo2S},
            {typeof(Pbm.Dsa.Start2S), PbmDsaStart2S},
            {typeof(Pbm.Room.StartGame2C), PbmRoomStartGame2C},
            {typeof(Pbm.Room.StartGame2S), PbmRoomStartGame2S},
            {typeof(Pbm.Room.Exit2C), PbmRoomExit2C},
            {typeof(Pbm.Room.Exit2S), PbmRoomExit2S},
            {typeof(Pbm.Room.ChangePosResult2C), PbmRoomChangePosResult2C},
            {typeof(Pbm.Room.ChangePosRefuse2C), PbmRoomChangePosRefuse2C},
            {typeof(Pbm.Room.ChangePosReply2S), PbmRoomChangePosReply2S},
            {typeof(Pbm.Room.ChangePosReq2C), PbmRoomChangePosReq2C},
            {typeof(Pbm.Room.ChangePos2S), PbmRoomChangePos2S},
            {typeof(Pbm.Room.Kick2C), PbmRoomKick2C},
            {typeof(Pbm.Room.Kick2S), PbmRoomKick2S},
            {typeof(Pbm.Room.Join2C), PbmRoomJoin2C},
            {typeof(Pbm.Room.Join2S), PbmRoomJoin2S},
            {typeof(Pbm.Room.QuickJoin2S), PbmRoomQuickJoin2S},
            {typeof(Pbm.Room.SetRoomMap2C), PbmRoomSetRoomMap2C},
            {typeof(Pbm.Room.SetRoomMap2S), PbmRoomSetRoomMap2S},
            {typeof(Pbm.Room.Create2C), PbmRoomCreate2C},
            {typeof(Pbm.Room.Create2S), PbmRoomCreate2S},
            {typeof(Pbm.Room.List2C), PbmRoomList2C},
            {typeof(Pbm.Room.List2S), PbmRoomList2S},
            {typeof(Pbm.Room.SetFilter2C), PbmRoomSetFilter2C},
            {typeof(Pbm.Room.SetFilter2S), PbmRoomSetFilter2S},
            {typeof(Pbm.Room.Update2C), PbmRoomUpdate2C},
            {typeof(Pbm.Room.Info2C), PbmRoomInfo2C},
            {typeof(Pbm.Room.Info2S), PbmRoomInfo2S},
            {typeof(Pbm.Chat.Chat2C), PbmChatChat2C},
            {typeof(Pbm.Chat.Chat2S), PbmChatChat2S},
            {typeof(Pbm.System.Error2C), PbmSystemError2C},
            {typeof(Pbm.Team.BeginMatch2S), PbmTeamBeginMatch2S},
            {typeof(Pbm.Team.Exit2C), PbmTeamExit2C},
            {typeof(Pbm.Team.Exit2S), PbmTeamExit2S},
            {typeof(Pbm.Team.Join2C), PbmTeamJoin2C},
            {typeof(Pbm.Team.InviteReply2C), PbmTeamInviteReply2C},
            {typeof(Pbm.Team.InviteReply2S), PbmTeamInviteReply2S},
            {typeof(Pbm.Team.InviteRequest2C), PbmTeamInviteRequest2C},
            {typeof(Pbm.Team.Invite2C), PbmTeamInvite2C},
            {typeof(Pbm.Team.Invite2S), PbmTeamInvite2S},
            {typeof(Pbm.Team.Create2C), PbmTeamCreate2C},
            {typeof(Pbm.Team.Create2S), PbmTeamCreate2S},
            {typeof(Pbm.Team.Info2C), PbmTeamInfo2C},
            {typeof(Pbm.Team.Info2S), PbmTeamInfo2S},

        };

        private static Dictionary<ushort, MessageParser> _dic_parser = new Dictionary<ushort, MessageParser>()
        {
            {PbmRoleSetName2C,  Pbm.Role.SetName2C.Parser},
            {PbmRoleSetName2S,  Pbm.Role.SetName2S.Parser},
            {PbmRoleOtherInfo2C,  Pbm.Role.OtherInfo2C.Parser},
            {PbmRoleOtherInfo2S,  Pbm.Role.OtherInfo2S.Parser},
            {PbmRoleInfo2C,  Pbm.Role.Info2C.Parser},
            {PbmRoleInfo2S,  Pbm.Role.Info2S.Parser},
            {PbmDsaPlayerQuit2S,  Pbm.Dsa.PlayerQuit2S.Parser},
            {PbmDsaPlayerState2S,  Pbm.Dsa.PlayerState2S.Parser},
            {PbmDsaHeartbeat2S,  Pbm.Dsa.Heartbeat2S.Parser},
            {PbmDsaRoleReady2S,  Pbm.Dsa.RoleReady2S.Parser},
            {PbmDsaRoleInfo2C,  Pbm.Dsa.RoleInfo2C.Parser},
            {PbmDsaBattleInfo2C,  Pbm.Dsa.BattleInfo2C.Parser},
            {PbmDsaBattleInfo2S,  Pbm.Dsa.BattleInfo2S.Parser},
            {PbmDsaStart2S,  Pbm.Dsa.Start2S.Parser},
            {PbmRoomStartGame2C,  Pbm.Room.StartGame2C.Parser},
            {PbmRoomStartGame2S,  Pbm.Room.StartGame2S.Parser},
            {PbmRoomExit2C,  Pbm.Room.Exit2C.Parser},
            {PbmRoomExit2S,  Pbm.Room.Exit2S.Parser},
            {PbmRoomChangePosResult2C,  Pbm.Room.ChangePosResult2C.Parser},
            {PbmRoomChangePosRefuse2C,  Pbm.Room.ChangePosRefuse2C.Parser},
            {PbmRoomChangePosReply2S,  Pbm.Room.ChangePosReply2S.Parser},
            {PbmRoomChangePosReq2C,  Pbm.Room.ChangePosReq2C.Parser},
            {PbmRoomChangePos2S,  Pbm.Room.ChangePos2S.Parser},
            {PbmRoomKick2C,  Pbm.Room.Kick2C.Parser},
            {PbmRoomKick2S,  Pbm.Room.Kick2S.Parser},
            {PbmRoomJoin2C,  Pbm.Room.Join2C.Parser},
            {PbmRoomJoin2S,  Pbm.Room.Join2S.Parser},
            {PbmRoomQuickJoin2S,  Pbm.Room.QuickJoin2S.Parser},
            {PbmRoomSetRoomMap2C,  Pbm.Room.SetRoomMap2C.Parser},
            {PbmRoomSetRoomMap2S,  Pbm.Room.SetRoomMap2S.Parser},
            {PbmRoomCreate2C,  Pbm.Room.Create2C.Parser},
            {PbmRoomCreate2S,  Pbm.Room.Create2S.Parser},
            {PbmRoomList2C,  Pbm.Room.List2C.Parser},
            {PbmRoomList2S,  Pbm.Room.List2S.Parser},
            {PbmRoomSetFilter2C,  Pbm.Room.SetFilter2C.Parser},
            {PbmRoomSetFilter2S,  Pbm.Room.SetFilter2S.Parser},
            {PbmRoomUpdate2C,  Pbm.Room.Update2C.Parser},
            {PbmRoomInfo2C,  Pbm.Room.Info2C.Parser},
            {PbmRoomInfo2S,  Pbm.Room.Info2S.Parser},
            {PbmChatChat2C,  Pbm.Chat.Chat2C.Parser},
            {PbmChatChat2S,  Pbm.Chat.Chat2S.Parser},
            {PbmSystemError2C,  Pbm.System.Error2C.Parser},
            {PbmTeamBeginMatch2S,  Pbm.Team.BeginMatch2S.Parser},
            {PbmTeamExit2C,  Pbm.Team.Exit2C.Parser},
            {PbmTeamExit2S,  Pbm.Team.Exit2S.Parser},
            {PbmTeamJoin2C,  Pbm.Team.Join2C.Parser},
            {PbmTeamInviteReply2C,  Pbm.Team.InviteReply2C.Parser},
            {PbmTeamInviteReply2S,  Pbm.Team.InviteReply2S.Parser},
            {PbmTeamInviteRequest2C,  Pbm.Team.InviteRequest2C.Parser},
            {PbmTeamInvite2C,  Pbm.Team.Invite2C.Parser},
            {PbmTeamInvite2S,  Pbm.Team.Invite2S.Parser},
            {PbmTeamCreate2C,  Pbm.Team.Create2C.Parser},
            {PbmTeamCreate2S,  Pbm.Team.Create2S.Parser},
            {PbmTeamInfo2C,  Pbm.Team.Info2C.Parser},
            {PbmTeamInfo2S,  Pbm.Team.Info2S.Parser},

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
