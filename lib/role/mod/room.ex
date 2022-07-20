defmodule Role.Mod.Room do
  defstruct room_id: 0, map_id: 0, status: 0
  use Role.Mod

  @doc """
  协议处理
  """
  def h(~M{%M room_id, map_id}, %Pbm.Room.Info2S{}) do
    with ~M{%Lobby.Room members,owner_id} <- Lobby.Svr.get_room_info(room_id) do
      room = ~M{%Pbm.Room.Room  room_id,owner_id,map_id,members}
      ~M{%Pbm.Room.Info2C room} |> sd()
    else
      _ ->
        room = ~M{%Pbm.Room.Room  room_id,map_id}
        ~M{%Pbm.Room.Info2C room} |> sd()
    end
  end

  def h(~M{%M } = state, ~M{%Pbm.Room.SetFilter2S map_id}) do
    ~M{%Pbm.Room.SetFilter2C map_id} |> sd()
    {:ok, ~M{state| map_id}}
  end

  # 请求房间列表
  def h(~M{%M map_id}, ~M{%Pbm.Room.List2S }) do
    Lobby.Svr.get_room_list([role_id(), map_id])
    :ok
  end

  def h(~M{%M room_id} = state, ~M{%Pbm.Room.Create2S map_id, password}) do
    if room_id != 0 do
      throw("已经在房间里了!")
    end

    with {:ok, room_id} <- Lobby.Svr.create_room([role_id(), map_id, password]) do
      ~M{%Pbm.Room.Create2C room_id} |> sd()
      {:ok, ~M{state | room_id}}
    else
      {:error, error} -> throw(error)
    end
  end

  def h(~M{%M room_id: cur_room_id} = state, ~M{%Pbm.Room.Join2S room_id,password}) do
    if cur_room_id != 0, do: throw("已经在房间里了")

    with :ok <- Lobby.Room.Svr.join(room_id, [role_id(), password]) do
      {:ok, ~M{state|room_id}}
    else
      {:error, error} -> throw(error)
    end
  end

  def h(~M{%M room_id,map_id} = state, ~M{%Pbm.Room.QuickJoin2S }) do
    if room_id > 0, do: throw("已经在房间里了!")

    with {:ok, room_id} <- Lobby.Svr.quick_join([role_id(), map_id]) do
      {:ok, ~M{state | room_id}}
    else
      {:error, error} ->
        throw(error)
    end
  end

  # 设置房间模式
  def h(~M{%M room_id}, ~M{%Pbm.Room.SetRoomMap2S map_id}) do
    with :ok <- Lobby.Room.Svr.set_map(room_id, [role_id(), map_id]) do
      :ok
    else
      {:error, error} -> throw(error)
    end
  end

  # 踢人
  def h(~M{%M room_id}, ~M{%Pbm.Room.Kick2S role_id}) do
    with :ok <- Lobby.Room.Svr.kick(room_id, [role_id(), role_id]) do
      :ok
    else
      {:error, error} -> throw(error)
    end
  end

  # 换位
  def h(~M{%M room_id}, ~M{%Pbm.Room.ChangePos2S position}) do
    with :ok <- Lobby.Room.Svr.change_pos(room_id, [role_id(), position]) do
      :ok
    else
      {:error, error} -> throw(error)
    end
  end

  # 退出房间
  def h(~M{%M room_id,map_id} = state, ~M{%Pbm.Room.Exit2S }) do
    with :ok <- Lobby.Room.Svr.exit_room(room_id, role_id()) do
      room = %Pbm.Room.Room{room_id: 0, map_id: map_id}
      %Pbm.Room.Update2C{room: room} |> sd()
      {:ok, ~M{state| room_id: 0}}
    else
      {:error, error} ->
        throw(error)
    end
  end

  # 开始游戏

  def h(~M{%M room_id}, ~M{%Pbm.Room.StartGame2S }) do
    with :ok <- Lobby.Room.Svr.start_game(room_id, role_id()) do
      :ok
    else
      _ ->
        :ok
    end
  end

  def on_offline(~M{%M room_id} = state) do
    Lobby.Room.Svr.exit_room(room_id, role_id())
    ~M{state | room_id:  0} |> set_data()
  end
end
