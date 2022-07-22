defmodule Lobby.Room do
  defstruct room_id: 0,
            owner_id: nil,
            status: 0,
            map_id: 0,
            members: %{},
            member_num: 0,
            create_time: 0,
            password: "",
            last_game_time: 0

  use Common
  alias __MODULE__, as: M

  @loop_interval 10_000
  @idle_time 3_600

  @positions [0, 5, 1, 6, 2, 7, 3, 8, 4, 9, 10, 11, 12]

  def init([room_id, owner_id, map_id, password]) do
    Logger.debug("Room.Svr room_id: [#{room_id}] owenr_id: [#{owner_id}]  start")
    :pg.join(M, self())
    create_time = Util.unixtime()
    last_game_time = create_time

    state =
      ~M{%M room_id,map_id,password,create_time,last_game_time,owner_id}
      |> do_join(owner_id)

    :ets.insert(Room, {room_id, state})
    Process.send_after(self(), :secondloop, @loop_interval)
    state
  end

  def to_common(data) do
    data = Map.from_struct(data)
    data = %Pbm.Room.Room{}.__struct__ |> struct(data)
    data
  end

  def secondloop(~M{%M room_id,member_num,last_game_time} = state) do
    now = Util.unixtime()

    if member_num == 0 or now >= last_game_time + @idle_time do
      self() |> Process.send(:shutdown, [:nosuspend])
    else
      Process.send_after(self(), :secondloop, @loop_interval)

      if dirty?() do
        :ets.insert(Room, {room_id, state})
        set_dirty(false)
      end
    end

    state
  end

  def set_map(~M{%owner_id} = state, [role_id, map_id]) do
    if role_id != owner_id do
      throw("你不是房主")
    end

    %Pbm.Room.SetRoomMap2C{role_id: role_id, map_id: map_id} |> broad_cast()
    ~M{state|map_id} |> sync() |> ok()
  end

  def kick(~M{%M owner_id,members,member_num} = state, [f_role_id, t_role_id]) do
    if f_role_id != owner_id do
      throw("你不是房主")
    end

    if not :ordsets.is_element(t_role_id, role_ids()) do
      throw("对方不在房间")
    end

    members =
      for {k, v} <- members, into: %{} do
        (v == t_role_id && nil) || v
        {k, v}
      end

    member_num = member_num - 1
    del_role_id(t_role_id)
    %Pbm.Room.Kick2C{role_id: t_role_id} |> broad_cast()
    Role.Svr.cast(t_role_id, {:kicked_from_room, f_role_id})
    ~M{state|members,member_num} |> sync() |> ok()
  end

  def change_pos(~M{%M members} = state, [role_id, position]) do
    if position not in @positions do
      throw("不是合法的位置")
    end

    with nil <- members[position] do
      members =
        members |> Map.filter(fn {_key, val} -> val != role_id end) |> Map.put(position, role_id)

      %Pbm.Room.ChangePosResult2C{members: members} |> broad_cast()
      ~M{state|members} |> sync |> ok()
    else
      t_role_id ->
        %Pbm.Room.ChangePosReq2C{role_id: role_id} |> Role.Misc.send_to(t_role_id)
        Process.put({:change_pos_req, role_id}, {t_role_id, Util.unixtime()})
        state |> ok()
    end
  end

  def change_pos_reply(~M{%M members} = state, [role_id, f_role_id, accept]) do
    with {^role_id, _timestamp} <- Process.get({:change_pos_req, f_role_id}) do
      Process.delete({:change_pos_req, f_role_id})

      if accept do
        members =
          for {k, v} <- members, into: %{} do
            v = (v == role_id && f_role_id) || (v == f_role_id && role_id) || v
            {k, v}
          end

        %Pbm.Room.ChangePosResult2C{members: members} |> broad_cast()
        ~M{state|members} |> sync |> ok()
      else
        %Pbm.Room.ChangePosRefuse2C{role_id: role_id} |> Role.Misc.send_to(f_role_id)
        state |> ok()
      end
    else
      _ ->
        state |> ok()
    end
  end

  def join(~M{%M room_id,password,member_num} = state, [role_id, tpassword]) do
    if password != "" && password != tpassword, do: throw("房间密码不正确")
    if member_num >= length(@positions), do: throw("房间已满")
    state = do_join(state, role_id)
    ~M{%Pbm.Room.Join2C role_id, room_id} |> broad_cast()
    state |> sync() |> ok()
  end

  defp do_join(~M{%M members, member_num} = state, role_id) do
    pos = find_free_pos(state)
    members = members |> Map.put(pos, role_id)
    add_role_id(role_id)
    member_num = member_num + 1
    ~M{state | member_num ,members}
  end

  @doc """
  开始游戏回调
  """
  def start_game(~M{%M room_id, owner_id, map_id, members} = state, role_id) do
    if role_id != owner_id, do: throw("你不是房主")
    Dsa.Svr.start_game([map_id, room_id, members])
    state |> ok()
  end

  def exit_room(~M{%M members,member_num,owner_id} = state, role_id) do
    if not :ordsets.is_element(role_id, role_ids()) do
      {:ok, state}
    else
      members =
        for {k, v} <- members, v != role_id, into: %{} do
          {k, v}
        end

      member_num = member_num - 1
      del_role_id(role_id)
      ~M{%Pbm.Room.Exit2C role_id} |> broad_cast()

      owner_id =
        if role_id == owner_id do
          role_ids() |> Util.rand_list() || 0
        else
          owner_id
        end

      if member_num == 0 do
        self() |> Process.send(:shutdown, [:nosuspend])
      end

      ~M{state| members,member_num,owner_id} |> sync() |> ok()
    end
  end

  defp find_free_pos(state, poses \\ @positions)
  defp find_free_pos(_state, []), do: throw("没有空余的位置了")

  defp find_free_pos(~M{%M members} = state, [pos | t]) do
    if members[pos] == nil do
      pos
    else
      find_free_pos(state, t)
    end
  end

  def set_dirty(dirty) do
    Process.put({M, :dirty}, dirty)
  end

  defp dirty?() do
    Process.get({M, :dirty}, false)
  end

  defp role_ids() do
    Process.get({M, :role_ids}, [])
  end

  defp set_role_ids(ids) do
    Process.put({M, :role_ids}, ids)
  end

  defp add_role_id(role_id) do
    :ordsets.add_element(role_id, role_ids())
    |> set_role_ids()
  end

  defp sync(~M{%M room_id, owner_id,status,member_num, map_id, members,create_time} = state) do
    room = ~M{%Pbm.Room.Room  room_id,owner_id,status,map_id,members,member_num,create_time}
    ~M{%Pbm.Room.Update2C room} |> broad_cast()
    state
  end

  defp del_role_id(role_id) do
    :ordsets.del_element(role_id, role_ids())
    |> set_role_ids()
  end

  def broad_cast(state, msg) do
    Logger.debug("broad cast #{inspect(msg)}")
    broad_cast(msg)
    state |> ok()
  end

  defp broad_cast(msg) do
    role_ids()
    |> Enum.each(&Role.Misc.send_to(msg, &1))
  end

  defp ok(state), do: {:ok, state}
end
