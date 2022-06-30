defmodule Lobby.Room do
  defstruct room_id: 0,
            type: 0,
            owner: nil,
            status: 0,
            roles: %{},
            member_num: 0,
            member_cap: 0,
            create_time: 0,
            password: ""

  def to_common(data) do
    data = Map.from_struct(data)
    data = struct(Common.Room, data)
    data
  end
end
