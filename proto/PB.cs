using System;
using Google.Protobuf;
namespace Script.Network
{
    public class PB
    {
		public const ushort ChatChat2C = 16613;
		public const ushort ChatChat2S = 63158;
		public const ushort SystemError2C = 18621;
		public const ushort SystemPing2S = 12961;


        public static ushort GetCmdID(IMessage obj)
        {
            Type type = obj.GetType();
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
			if (type == typeof(System.Ping2S))
			{
			    return SystemPing2S;
			}

            return 0;
        }

        public static MessageParser GetParser(ushort id)
        {
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
			if (id == SystemPing2S)
			{
			    return System.Ping2S.Parser;
			}

            return null;
        }
    }
}
