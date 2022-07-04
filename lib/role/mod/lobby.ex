defmodule Role.Mod.Lobby do
  defstruct status: 0, mode: 0
  use Role.Mod

  @doc """
  协议处理
  """
  def h(~M{%__MODULE__ }, %Lobby.Info2S{}) do
    ~M{room_id} = Role.Mod.Room.get_data()

    if room_id > 0 do
      ~M{%Lobby.Info2C room_id} |> sd()
    else
      Role.Mod.Role.common_data()
      |> Lobby.Svr.enter()
    end

    :ok
  end

  def h(_state, %Lobby.Heart2S{}) do
    role_id() |> Lobby.Svr.heart()
  end

  def h(_state, ~M{%Lobby.CreatRoom2S type, member_cap,password}) do
    ~M{room_id} = Role.Mod.Room.get_data()

    if room_id == 0 do
      {:ok, room_id} = Lobby.Svr.create_room(~M{role_id(), type, member_cap, password})
      %Lobby.CreatRoom2C{room_id: room_id} |> sd()
      Role.Mod.Room.set_room_id(room_id)
      :ok
    else
      sd_err(0, "已经在房间里了")
    end
  end

  def h(~M{%__MODULE__ } = state, ~M{%Lobby.JoinRoom2S room_id,password}) do
    ~M{room_id} = Role.Mod.Room.get_data()

    if room_id == 0 do
      Lobby.Svr.join({room_id, role_id(), password})
    else
      sd_err(0, "已经在房间里了")
    end

    :ok
  end

  @doc """
  下线回调
  """
  def on_offline(_state) do
    role_id() |> Lobby.Svr.offline()
  end
end
