using System;
using Google.Protobuf;
using System.Collections.Generic;
namespace Script.Network
{
    public class PB
    {
		public const ushort RoleSetName2C = 18252;
		public const ushort RoleSetName2S = 17898;
		public const ushort RoleOtherInfo2C = 52306;
		public const ushort RoleOtherInfo2S = 29210;
		public const ushort RoleInfo2C = 65516;
		public const ushort RoleInfo2S = 37482;
		public const ushort RoomStartGame2C = 60718;
		public const ushort RoomStartGame2S = 45263;
		public const ushort RoomExit2C = 9866;
		public const ushort RoomExit2S = 30965;
		public const ushort RoomChangePosResult2C = 62553;
		public const ushort RoomChangePosRefuse2C = 43016;
		public const ushort RoomChangePosReply2S = 43952;
		public const ushort RoomChangePosReq2C = 17644;
		public const ushort RoomChangePos2S = 22506;
		public const ushort RoomKick2C = 58060;
		public const ushort RoomKick2S = 32533;
		public const ushort RoomJoin2C = 54938;
		public const ushort RoomJoin2S = 8120;
		public const ushort RoomQuickJoin2S = 4770;
		public const ushort RoomCreat2C = 29100;
		public const ushort RoomCreat2S = 44306;
		public const ushort RoomList2C = 37512;
		public const ushort RoomList2S = 22718;
		public const ushort RoomSetFilter2C = 42712;
		public const ushort RoomSetFilter2S = 44574;
		public const ushort RoomUpdate2C = 37580;
		public const ushort RoomInfo2C = 11303;
		public const ushort RoomInfo2S = 55363;
		public const ushort ChatChat2C = 16613;
		public const ushort ChatChat2S = 63158;
		public const ushort SystemError2C = 18621;


        private static var _dic_id = new Dictionary<Type, ushort>()
        {
			{typeof(Role.SetName2C), RoleSetName2C},
			{typeof(Role.SetName2S), RoleSetName2S},
			{typeof(Role.OtherInfo2C), RoleOtherInfo2C},
			{typeof(Role.OtherInfo2S), RoleOtherInfo2S},
			{typeof(Role.Info2C), RoleInfo2C},
			{typeof(Role.Info2S), RoleInfo2S},
			{typeof(Room.StartGame2C), RoomStartGame2C},
			{typeof(Room.StartGame2S), RoomStartGame2S},
			{typeof(Room.Exit2C), RoomExit2C},
			{typeof(Room.Exit2S), RoomExit2S},
			{typeof(Room.ChangePosResult2C), RoomChangePosResult2C},
			{typeof(Room.ChangePosRefuse2C), RoomChangePosRefuse2C},
			{typeof(Room.ChangePosReply2S), RoomChangePosReply2S},
			{typeof(Room.ChangePosReq2C), RoomChangePosReq2C},
			{typeof(Room.ChangePos2S), RoomChangePos2S},
			{typeof(Room.Kick2C), RoomKick2C},
			{typeof(Room.Kick2S), RoomKick2S},
			{typeof(Room.Join2C), RoomJoin2C},
			{typeof(Room.Join2S), RoomJoin2S},
			{typeof(Room.QuickJoin2S), RoomQuickJoin2S},
			{typeof(Room.Creat2C), RoomCreat2C},
			{typeof(Room.Creat2S), RoomCreat2S},
			{typeof(Room.List2C), RoomList2C},
			{typeof(Room.List2S), RoomList2S},
			{typeof(Room.SetFilter2C), RoomSetFilter2C},
			{typeof(Room.SetFilter2S), RoomSetFilter2S},
			{typeof(Room.Update2C), RoomUpdate2C},
			{typeof(Room.Info2C), RoomInfo2C},
			{typeof(Room.Info2S), RoomInfo2S},
			{typeof(Chat.Chat2C), ChatChat2C},
			{typeof(Chat.Chat2S), ChatChat2S},
			{typeof(System.Error2C), SystemError2C},

        };

        private static var _dic_parser = new Dictionary<ushort, MessageParser>()
        {
			{RoleSetName2C,  Role.SetName2C.Parser},
			{RoleSetName2S,  Role.SetName2S.Parser},
			{RoleOtherInfo2C,  Role.OtherInfo2C.Parser},
			{RoleOtherInfo2S,  Role.OtherInfo2S.Parser},
			{RoleInfo2C,  Role.Info2C.Parser},
			{RoleInfo2S,  Role.Info2S.Parser},
			{RoomStartGame2C,  Room.StartGame2C.Parser},
			{RoomStartGame2S,  Room.StartGame2S.Parser},
			{RoomExit2C,  Room.Exit2C.Parser},
			{RoomExit2S,  Room.Exit2S.Parser},
			{RoomChangePosResult2C,  Room.ChangePosResult2C.Parser},
			{RoomChangePosRefuse2C,  Room.ChangePosRefuse2C.Parser},
			{RoomChangePosReply2S,  Room.ChangePosReply2S.Parser},
			{RoomChangePosReq2C,  Room.ChangePosReq2C.Parser},
			{RoomChangePos2S,  Room.ChangePos2S.Parser},
			{RoomKick2C,  Room.Kick2C.Parser},
			{RoomKick2S,  Room.Kick2S.Parser},
			{RoomJoin2C,  Room.Join2C.Parser},
			{RoomJoin2S,  Room.Join2S.Parser},
			{RoomQuickJoin2S,  Room.QuickJoin2S.Parser},
			{RoomCreat2C,  Room.Creat2C.Parser},
			{RoomCreat2S,  Room.Creat2S.Parser},
			{RoomList2C,  Room.List2C.Parser},
			{RoomList2S,  Room.List2S.Parser},
			{RoomSetFilter2C,  Room.SetFilter2C.Parser},
			{RoomSetFilter2S,  Room.SetFilter2S.Parser},
			{RoomUpdate2C,  Room.Update2C.Parser},
			{RoomInfo2C,  Room.Info2C.Parser},
			{RoomInfo2S,  Room.Info2S.Parser},
			{ChatChat2C,  Chat.Chat2C.Parser},
			{ChatChat2S,  Chat.Chat2S.Parser},
			{SystemError2C,  System.Error2C.Parser},

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
