defmodule Role.Mod.Room do
  defstruct room_id: 0, mode: 0, map_id: 0, status: 0
  use Role.Mod

  @doc """
  协议处理
  """
  def h(~M{%__MODULE__ room_id, mode, map_id}, %Room.Info2S{}) do
    with ~M{members,owner_id} <- Lobby.Svr.get_room_info(room_id) do
      ~M{%Room.Info2C room_id,owner_id,map_id,mode,members} |> sd()
    else
      _ ->
        ~M{%Room.Info2C room_id,map_id,mode} |> sd()
    end
  end

  def h(~M{%__MODULE__ } = state, ~M{%Room.SetFilter2S mode}) do
    ~M{%Room.SetFilter2C mode} |> sd()
    {:ok, ~M{state| mode}}
  end

  # 请求房间列表
  def h(~M{%__MODULE__ mode,map_id}, ~M{%Room.List2S }) do
    Lobby.Svr.get_room_list([mode, map_id])
    :ok
  end

  def h(~M{%__MODULE__ room_id} = state, ~M{%Room.Creat2S mode, map_id, password}) do
    if room_id == 0 do
      {:ok, room_id} = Lobby.Svr.create_room([role_id(), mode, map_id, password])
      ~M{%Room.Creat2C room_id} |> sd()
      {:ok, ~M{state | room_id}}
    else
      sd_err(0, "已经在房间里了")
      :ok
    end
  end

  def h(~M{%__MODULE__ room_id,mode,map_id} = state, ~M{%Room.QuickJoin2S }) do
    with 0 <- room_id,
         {:ok, room_id} <- Lobby.Svr.quick_join([role_id(), mode, map_id]) do
      {:ok, ~M{state | room_id}}
    else
      {:error, _reason} ->
        sd_err(0, "没有可以加入的房间 !")

      _ ->
        sd_err(0, "已经在房间里了")
    end
  end

  # 踢人
  def h(~M{%__MODULE__ room_id}, ~M{%Room.Kick2S role_id}) do
    Lobby.Room.Svr.kick(room_id, [role_id(), role_id])
    :ok
  end

  # 换位
  def h(~M{%__MODULE__ room_id}, ~M{%Room.ChangePos2S position}) do
    Lobby.Room.Svr.change_pos(room_id, [role_id(), position])
    :ok
  end

  # 退出房间
  def h(~M{%__MODULE__ room_id} = state, ~M{%Room.Exit2S }) do
    with :ok <- Lobby.Room.Svr.exit_room(room_id, role_id()) do
      {:ok, ~M{state| room_id: 0}}
    else
      _ ->
        :ok
    end
  end

  # 开始游戏
  def h(~M{%__MODULE__ room_id}, ~M{%Room.StartGame2C }) do
    with :ok <- Lobby.Room.Svr.start_game(room_id, role_id()) do
    else
      _ ->
        :ok
    end
  end

  def set_room_id(room_id) do
    with %__MODULE__{} = data <- get_data() do
      set_data(~M{%__MODULE__ data| room_id})
    else
      _ ->
        Logger.warn("role room data is unexpected ...")
    end
  end
end
