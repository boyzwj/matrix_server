using System;
using Google.Protobuf;
using System.Collections.Generic;
namespace Script.Network
{
    public class PB
    {
        public const ushort PbmroleSetName2C = 33626;
        public const ushort PbmroleSetName2S = 5545;
        public const ushort PbmroleOtherInfo2C = 7824;
        public const ushort PbmroleOtherInfo2S = 28869;
        public const ushort PbmroleInfo2C = 36944;
        public const ushort PbmroleInfo2S = 12067;
        public const ushort PbmroomStartGame2C = 5358;
        public const ushort PbmroomStartGame2S = 14753;
        public const ushort PbmroomExit2C = 5193;
        public const ushort PbmroomExit2S = 53057;
        public const ushort PbmroomChangePosResult2C = 57022;
        public const ushort PbmroomChangePosRefuse2C = 34405;
        public const ushort PbmroomChangePosReply2S = 15571;
        public const ushort PbmroomChangePosReq2C = 30904;
        public const ushort PbmroomChangePos2S = 29611;
        public const ushort PbmroomKick2C = 41689;
        public const ushort PbmroomKick2S = 3464;
        public const ushort PbmroomJoin2C = 32717;
        public const ushort PbmroomJoin2S = 62685;
        public const ushort PbmroomQuickJoin2S = 52306;
        public const ushort PbmroomCreate2C = 10725;
        public const ushort PbmroomCreate2S = 60937;
        public const ushort PbmroomList2C = 28394;
        public const ushort PbmroomList2S = 34037;
        public const ushort PbmroomSetFilter2C = 8178;
        public const ushort PbmroomSetFilter2S = 39132;
        public const ushort PbmroomUpdate2C = 4276;
        public const ushort PbmroomInfo2C = 11270;
        public const ushort PbmroomInfo2S = 9300;
        public const ushort PbmchatChat2C = 21063;
        public const ushort PbmchatChat2S = 30949;
        public const ushort PbmsystemError2C = 39255;
        public const ushort PbmteamBeginMatch2S = 47184;
        public const ushort PbmteamExit2C = 47963;
        public const ushort PbmteamExit2S = 1742;
        public const ushort PbmteamJoin2C = 12761;
        public const ushort PbmteamInviteReply2C = 46527;
        public const ushort PbmteamInviteReply2S = 63283;
        public const ushort PbmteamInviteRequest2C = 57212;
        public const ushort PbmteamInvite2C = 64065;
        public const ushort PbmteamInvite2S = 6313;
        public const ushort PbmteamCreate2C = 56640;
        public const ushort PbmteamCreate2S = 54299;
        public const ushort PbmteamInfo2C = 13874;
        public const ushort PbmteamInfo2S = 29162;


        private static Dictionary<Type, ushort> _dic_id = new Dictionary<Type, ushort>()
        {
            {typeof(Pbm.role.SetName2C), PbmroleSetName2C},
            {typeof(Pbm.role.SetName2S), PbmroleSetName2S},
            {typeof(Pbm.role.OtherInfo2C), PbmroleOtherInfo2C},
            {typeof(Pbm.role.OtherInfo2S), PbmroleOtherInfo2S},
            {typeof(Pbm.role.Info2C), PbmroleInfo2C},
            {typeof(Pbm.role.Info2S), PbmroleInfo2S},
            {typeof(Pbm.room.StartGame2C), PbmroomStartGame2C},
            {typeof(Pbm.room.StartGame2S), PbmroomStartGame2S},
            {typeof(Pbm.room.Exit2C), PbmroomExit2C},
            {typeof(Pbm.room.Exit2S), PbmroomExit2S},
            {typeof(Pbm.room.ChangePosResult2C), PbmroomChangePosResult2C},
            {typeof(Pbm.room.ChangePosRefuse2C), PbmroomChangePosRefuse2C},
            {typeof(Pbm.room.ChangePosReply2S), PbmroomChangePosReply2S},
            {typeof(Pbm.room.ChangePosReq2C), PbmroomChangePosReq2C},
            {typeof(Pbm.room.ChangePos2S), PbmroomChangePos2S},
            {typeof(Pbm.room.Kick2C), PbmroomKick2C},
            {typeof(Pbm.room.Kick2S), PbmroomKick2S},
            {typeof(Pbm.room.Join2C), PbmroomJoin2C},
            {typeof(Pbm.room.Join2S), PbmroomJoin2S},
            {typeof(Pbm.room.QuickJoin2S), PbmroomQuickJoin2S},
            {typeof(Pbm.room.Create2C), PbmroomCreate2C},
            {typeof(Pbm.room.Create2S), PbmroomCreate2S},
            {typeof(Pbm.room.List2C), PbmroomList2C},
            {typeof(Pbm.room.List2S), PbmroomList2S},
            {typeof(Pbm.room.SetFilter2C), PbmroomSetFilter2C},
            {typeof(Pbm.room.SetFilter2S), PbmroomSetFilter2S},
            {typeof(Pbm.room.Update2C), PbmroomUpdate2C},
            {typeof(Pbm.room.Info2C), PbmroomInfo2C},
            {typeof(Pbm.room.Info2S), PbmroomInfo2S},
            {typeof(Pbm.chat.Chat2C), PbmchatChat2C},
            {typeof(Pbm.chat.Chat2S), PbmchatChat2S},
            {typeof(Pbm.system.Error2C), PbmsystemError2C},
            {typeof(Pbm.team.BeginMatch2S), PbmteamBeginMatch2S},
            {typeof(Pbm.team.Exit2C), PbmteamExit2C},
            {typeof(Pbm.team.Exit2S), PbmteamExit2S},
            {typeof(Pbm.team.Join2C), PbmteamJoin2C},
            {typeof(Pbm.team.InviteReply2C), PbmteamInviteReply2C},
            {typeof(Pbm.team.InviteReply2S), PbmteamInviteReply2S},
            {typeof(Pbm.team.InviteRequest2C), PbmteamInviteRequest2C},
            {typeof(Pbm.team.Invite2C), PbmteamInvite2C},
            {typeof(Pbm.team.Invite2S), PbmteamInvite2S},
            {typeof(Pbm.team.Create2C), PbmteamCreate2C},
            {typeof(Pbm.team.Create2S), PbmteamCreate2S},
            {typeof(Pbm.team.Info2C), PbmteamInfo2C},
            {typeof(Pbm.team.Info2S), PbmteamInfo2S},

        };

        private static Dictionary<ushort, MessageParser> _dic_parser = new Dictionary<ushort, MessageParser>()
        {
            {PbmroleSetName2C,  Pbm.role.SetName2C.Parser},
            {PbmroleSetName2S,  Pbm.role.SetName2S.Parser},
            {PbmroleOtherInfo2C,  Pbm.role.OtherInfo2C.Parser},
            {PbmroleOtherInfo2S,  Pbm.role.OtherInfo2S.Parser},
            {PbmroleInfo2C,  Pbm.role.Info2C.Parser},
            {PbmroleInfo2S,  Pbm.role.Info2S.Parser},
            {PbmroomStartGame2C,  Pbm.room.StartGame2C.Parser},
            {PbmroomStartGame2S,  Pbm.room.StartGame2S.Parser},
            {PbmroomExit2C,  Pbm.room.Exit2C.Parser},
            {PbmroomExit2S,  Pbm.room.Exit2S.Parser},
            {PbmroomChangePosResult2C,  Pbm.room.ChangePosResult2C.Parser},
            {PbmroomChangePosRefuse2C,  Pbm.room.ChangePosRefuse2C.Parser},
            {PbmroomChangePosReply2S,  Pbm.room.ChangePosReply2S.Parser},
            {PbmroomChangePosReq2C,  Pbm.room.ChangePosReq2C.Parser},
            {PbmroomChangePos2S,  Pbm.room.ChangePos2S.Parser},
            {PbmroomKick2C,  Pbm.room.Kick2C.Parser},
            {PbmroomKick2S,  Pbm.room.Kick2S.Parser},
            {PbmroomJoin2C,  Pbm.room.Join2C.Parser},
            {PbmroomJoin2S,  Pbm.room.Join2S.Parser},
            {PbmroomQuickJoin2S,  Pbm.room.QuickJoin2S.Parser},
            {PbmroomCreate2C,  Pbm.room.Create2C.Parser},
            {PbmroomCreate2S,  Pbm.room.Create2S.Parser},
            {PbmroomList2C,  Pbm.room.List2C.Parser},
            {PbmroomList2S,  Pbm.room.List2S.Parser},
            {PbmroomSetFilter2C,  Pbm.room.SetFilter2C.Parser},
            {PbmroomSetFilter2S,  Pbm.room.SetFilter2S.Parser},
            {PbmroomUpdate2C,  Pbm.room.Update2C.Parser},
            {PbmroomInfo2C,  Pbm.room.Info2C.Parser},
            {PbmroomInfo2S,  Pbm.room.Info2S.Parser},
            {PbmchatChat2C,  Pbm.chat.Chat2C.Parser},
            {PbmchatChat2S,  Pbm.chat.Chat2S.Parser},
            {PbmsystemError2C,  Pbm.system.Error2C.Parser},
            {PbmteamBeginMatch2S,  Pbm.team.BeginMatch2S.Parser},
            {PbmteamExit2C,  Pbm.team.Exit2C.Parser},
            {PbmteamExit2S,  Pbm.team.Exit2S.Parser},
            {PbmteamJoin2C,  Pbm.team.Join2C.Parser},
            {PbmteamInviteReply2C,  Pbm.team.InviteReply2C.Parser},
            {PbmteamInviteReply2S,  Pbm.team.InviteReply2S.Parser},
            {PbmteamInviteRequest2C,  Pbm.team.InviteRequest2C.Parser},
            {PbmteamInvite2C,  Pbm.team.Invite2C.Parser},
            {PbmteamInvite2S,  Pbm.team.Invite2S.Parser},
            {PbmteamCreate2C,  Pbm.team.Create2C.Parser},
            {PbmteamCreate2S,  Pbm.team.Create2S.Parser},
            {PbmteamInfo2C,  Pbm.team.Info2C.Parser},
            {PbmteamInfo2S,  Pbm.team.Info2S.Parser},

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
