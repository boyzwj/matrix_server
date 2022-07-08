using System;
using Google.Protobuf;
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


        public static ushort GetCmdID(IMessage obj)
        {
            Type type = obj.GetType();
  			if (type == typeof(Role.SetName2C))
			{
			    return RoleSetName2C;
			}
			if (type == typeof(Role.SetName2S))
			{
			    return RoleSetName2S;
			}
			if (type == typeof(Role.OtherInfo2C))
			{
			    return RoleOtherInfo2C;
			}
			if (type == typeof(Role.OtherInfo2S))
			{
			    return RoleOtherInfo2S;
			}
			if (type == typeof(Role.Info2C))
			{
			    return RoleInfo2C;
			}
			if (type == typeof(Role.Info2S))
			{
			    return RoleInfo2S;
			}
			if (type == typeof(Room.StartGame2C))
			{
			    return RoomStartGame2C;
			}
			if (type == typeof(Room.StartGame2S))
			{
			    return RoomStartGame2S;
			}
			if (type == typeof(Room.Exit2C))
			{
			    return RoomExit2C;
			}
			if (type == typeof(Room.Exit2S))
			{
			    return RoomExit2S;
			}
			if (type == typeof(Room.ChangePosResult2C))
			{
			    return RoomChangePosResult2C;
			}
			if (type == typeof(Room.ChangePosRefuse2C))
			{
			    return RoomChangePosRefuse2C;
			}
			if (type == typeof(Room.ChangePosReply2S))
			{
			    return RoomChangePosReply2S;
			}
			if (type == typeof(Room.ChangePosReq2C))
			{
			    return RoomChangePosReq2C;
			}
			if (type == typeof(Room.ChangePos2S))
			{
			    return RoomChangePos2S;
			}
			if (type == typeof(Room.Kick2C))
			{
			    return RoomKick2C;
			}
			if (type == typeof(Room.Kick2S))
			{
			    return RoomKick2S;
			}
			if (type == typeof(Room.Join2C))
			{
			    return RoomJoin2C;
			}
			if (type == typeof(Room.Join2S))
			{
			    return RoomJoin2S;
			}
			if (type == typeof(Room.QuickJoin2S))
			{
			    return RoomQuickJoin2S;
			}
			if (type == typeof(Room.Creat2C))
			{
			    return RoomCreat2C;
			}
			if (type == typeof(Room.Creat2S))
			{
			    return RoomCreat2S;
			}
			if (type == typeof(Room.List2C))
			{
			    return RoomList2C;
			}
			if (type == typeof(Room.List2S))
			{
			    return RoomList2S;
			}
			if (type == typeof(Room.SetFilter2C))
			{
			    return RoomSetFilter2C;
			}
			if (type == typeof(Room.SetFilter2S))
			{
			    return RoomSetFilter2S;
			}
			if (type == typeof(Room.Update2C))
			{
			    return RoomUpdate2C;
			}
			if (type == typeof(Room.Info2C))
			{
			    return RoomInfo2C;
			}
			if (type == typeof(Room.Info2S))
			{
			    return RoomInfo2S;
			}
			if (type == typeof(Chat.Chat2C))
			{
			    return ChatChat2C;
			}
			if (type == typeof(Chat.Chat2S))
			{
			    return ChatChat2S;
			}
			if (type == typeof(System.Error2C))
			{
			    return SystemError2C;
			}

            return 0;
        }

        public static MessageParser GetParser(ushort id)
        {
			if (id == RoleSetName2C)
			{
			    return Role.SetName2C.Parser;
			}
			if (id == RoleSetName2S)
			{
			    return Role.SetName2S.Parser;
			}
			if (id == RoleOtherInfo2C)
			{
			    return Role.OtherInfo2C.Parser;
			}
			if (id == RoleOtherInfo2S)
			{
			    return Role.OtherInfo2S.Parser;
			}
			if (id == RoleInfo2C)
			{
			    return Role.Info2C.Parser;
			}
			if (id == RoleInfo2S)
			{
			    return Role.Info2S.Parser;
			}
			if (id == RoomStartGame2C)
			{
			    return Room.StartGame2C.Parser;
			}
			if (id == RoomStartGame2S)
			{
			    return Room.StartGame2S.Parser;
			}
			if (id == RoomExit2C)
			{
			    return Room.Exit2C.Parser;
			}
			if (id == RoomExit2S)
			{
			    return Room.Exit2S.Parser;
			}
			if (id == RoomChangePosResult2C)
			{
			    return Room.ChangePosResult2C.Parser;
			}
			if (id == RoomChangePosRefuse2C)
			{
			    return Room.ChangePosRefuse2C.Parser;
			}
			if (id == RoomChangePosReply2S)
			{
			    return Room.ChangePosReply2S.Parser;
			}
			if (id == RoomChangePosReq2C)
			{
			    return Room.ChangePosReq2C.Parser;
			}
			if (id == RoomChangePos2S)
			{
			    return Room.ChangePos2S.Parser;
			}
			if (id == RoomKick2C)
			{
			    return Room.Kick2C.Parser;
			}
			if (id == RoomKick2S)
			{
			    return Room.Kick2S.Parser;
			}
			if (id == RoomJoin2C)
			{
			    return Room.Join2C.Parser;
			}
			if (id == RoomJoin2S)
			{
			    return Room.Join2S.Parser;
			}
			if (id == RoomQuickJoin2S)
			{
			    return Room.QuickJoin2S.Parser;
			}
			if (id == RoomCreat2C)
			{
			    return Room.Creat2C.Parser;
			}
			if (id == RoomCreat2S)
			{
			    return Room.Creat2S.Parser;
			}
			if (id == RoomList2C)
			{
			    return Room.List2C.Parser;
			}
			if (id == RoomList2S)
			{
			    return Room.List2S.Parser;
			}
			if (id == RoomSetFilter2C)
			{
			    return Room.SetFilter2C.Parser;
			}
			if (id == RoomSetFilter2S)
			{
			    return Room.SetFilter2S.Parser;
			}
			if (id == RoomUpdate2C)
			{
			    return Room.Update2C.Parser;
			}
			if (id == RoomInfo2C)
			{
			    return Room.Info2C.Parser;
			}
			if (id == RoomInfo2S)
			{
			    return Room.Info2S.Parser;
			}
			if (id == ChatChat2C)
			{
			    return Chat.Chat2C.Parser;
			}
			if (id == ChatChat2S)
			{
			    return Chat.Chat2S.Parser;
			}
			if (id == SystemError2C)
			{
			    return System.Error2C.Parser;
			}

            return null;
        }
    }
}
