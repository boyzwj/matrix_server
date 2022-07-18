defmodule Lobby.Room do
  defstruct room_id: 0,
            owner_id: nil,
            status: 0,
            map_id: 0,
            positions: %{},
            member_num: 0,
            create_time: 0,
            password: "",
            last_game_time: 0

  use Common
  alias __MODULE__, as: M

  @loop_interval 10_000
  @idle_time 3_600
  @positions [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

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
    data = struct(Room.Room, data)
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

  def kick(~M{%M owner_id,positions,member_num} = state, [f_role_id, t_role_id]) do
    if f_role_id != owner_id do
      throw("你不是房主")
    end

    if not :ordsets.is_element(t_role_id, role_ids()) do
      throw("对方不在房间")
    end

    positions =
      for {k, v} <- positions, v != t_role_id, into: %{} do
        {k, v}
      end

    member_num = member_num - 1
    del_role_id(t_role_id)
    %Room.Kick2C{role_id: t_role_id} |> broad_cast()
    ~M{state|positions,member_num} |> sync() |> ok()
  end

  def join(~M{%M room_id,password,member_num} = state, [role_id, tpassword]) do
    if password != "" && password != tpassword, do: throw("房间密码不正确")
    if member_num >= length(@positions), do: throw("房间已满")
    state = do_join(state, role_id)
    ~M{%Room.Join2C role_id, room_id} |> broad_cast()
    state |> sync() |> ok()
  end

  defp do_join(~M{%M positions, member_num} = state, role_id) do
    pos = find_free_pos(state)
    positions = positions |> Map.put(pos, role_id)
    add_role_id(role_id)
    member_num = member_num + 1
    ~M{state | member_num ,positions}
  end

  @doc """
  开始游戏回调
  """
  def start_game(~M{%M room_id, owner_id, map_id, positions} = state, role_id) do
    if role_id != owner_id, do: throw("你不是房主")
    Dsa.Svr.start_game([map_id, room_id, positions])
    state |> ok()
  end

  def exit_room(~M{%M positions,member_num,owner_id} = state, role_id) do
    if not :ordsets.is_element(role_id, role_ids()) do
      {:ok, state}
    else
      positions =
        for {k, v} <- positions, v != role_id, into: %{} do
          {k, v}
        end

      member_num = member_num - 1
      del_role_id(role_id)
      ~M{%Room.Exit2C role_id} |> broad_cast()

      owner_id =
        if role_id == owner_id do
          role_ids() |> Util.rand_list() || 0
        else
          owner_id
        end

      if member_num == 0 do
        self() |> Process.send(:shutdown, [:nosuspend])
      end

      ~M{state| positions,member_num,owner_id} |> sync() |> ok()
    end
  end

  defp find_free_pos(state, poses \\ @positions)
  defp find_free_pos(_state, []), do: throw("没有空余的位置了")

  defp find_free_pos(~M{%M positions} = state, [pos | t]) do
    if positions[pos] == nil do
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

  defp sync(~M{%M room_id, owner_id,status,member_num, map_id, positions,create_time} = state) do
    members =
      for {k, v} <- positions, not is_nil(v) do
        %Room.Member{role_id: v, position: k}
      end

    room = ~M{%Room.Room  room_id,owner_id,status,map_id,members,member_num,create_time}
    ~M{%Room.Update2C room} |> broad_cast()
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
