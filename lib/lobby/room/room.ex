defmodule Lobby.Room do
  defstruct room_id: 0,
            mode: 0,
            owner: nil,
            status: 0,
            positions: %{},
            member_num: 0,
            map_id: 0,
            create_time: 0,
            password: "",
            last_game_time: 0

  use Common
  alias __MODULE__, as: M

  @loop_interval 10_000
  @idle_time 3_600
  @positions [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

  def init([room_id, owner, mode, map_id, password]) do
    Logger.debug("Room.Svr [#{room_id}]  start")
    :pg.join(M, self())
    create_time = Util.unixtime()
    last_game_time = create_time
    state = ~M{%M room_id,mode,map_id,password,create_time,last_game_time,owner}
    :ets.insert(Room, {room_id, state})
    Process.send_after(self(), :secondloop, @loop_interval)
    state
  end

  def to_common(data) do
    data = Map.from_struct(data)
    data = struct(Common.Room, data)
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

  def kick(~M{%M owner,positions,member_num} = state, [f_role_id, t_role_id]) do
    if f_role_id != owner do
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
    {:ok, ~M{state|positions,member_num}}
  end

  def join(~M{%M room_id,password,member_num} = state, [role_id, tpassword]) do
    if password != "" && password != tpassword, do: throw("房间密码不正确")
    if member_num >= length(@positions), do: throw("房间已满")
    state = do_join(state, role_id)
    ~M{%Room.Join2C role_id, room_id} |> broad_cast()
    state
  end

  defp do_join(~M{%M positions, member_num} = state, role_id) do
    pos = find_free_pos(state)
    positions = positions |> Map.put(pos, role_id)
    add_role_id(role_id)
    member_num = member_num + 1
    ~M{state | member_num ,positions}
  end

  def exit_room(~M{%M positions,member_num} = state, role_id) do
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
      {:ok, ~M{state| positions,member_num}}
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

  defp del_role_id(role_id) do
    :ordsets.del_element(role_id, role_ids())
    |> set_role_ids()
  end

  defp broad_cast(msg) do
    role_ids()
    |> Enum.each(&Role.Misc.send_to(msg, &1))
  end
end
