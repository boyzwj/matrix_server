defmodule Lobby.Room do
  defstruct room_id: 0,
            type: 0,
            owner: nil,
            status: 0,
            positions: %{},
            member_num: 0,
            member_cap: 0,
            create_time: 0,
            password: "",
            last_game_time: 0

  use Common
  alias __MODULE__, as: M

  @loop_interval 10_000
  @idle_time 3_600

  def init([room_id, owner, type, member_cap, password]) do
    Logger.debug("Room.Svr [#{room_id}]  start")
    :pg.join(M, self())
    create_time = Util.unixtime()
    last_game_time = create_time
    state = ~M{%M  room_id,type,member_cap,password,create_time,last_game_time,owner}
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

  def kick(~M{%M owner} = state, [f_role_id, t_role_id]) do
    if f_role_id == owner do
      if :ordsets.is_element(t_role_id, role_ids()) do
      else
      end

      :ok
    else
      %System.Error2C{error_msg: "你不是房主"} |> Role.Misc.send_to(f_role_id)
      state
    end
  end

  def set_dirty(dirty) do
    Process.put({M, :dirty}, dirty)
  end

  def dirty?() do
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
