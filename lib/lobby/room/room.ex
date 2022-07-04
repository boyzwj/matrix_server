defmodule Lobby.Room do
  defstruct room_id: 0,
            type: 0,
            owner: nil,
            status: 0,
            positions: %{},
            member_num: 0,
            member_cap: 0,
            create_time: 0,
            password: ""

  use Common

  def to_common(data) do
    data = Map.from_struct(data)
    data = struct(Common.Room, data)
    data
  end

  def secondloop(~M{%__MODULE__ member_num} = state) do
    if member_num == 0 do
      self() |> Process.send(:shutdown, [:nosuspend])
    end

    state
  end
end
