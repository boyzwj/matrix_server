defmodule Role.Mod.Lobby do
  defstruct room_id: 0, status: 0
  use Role.Mod

  def h(~M{%__MODULE__ room_id}, %Lobby.Info2S{}) do
    if room_id > 0 do
      ~M{%Lobby.Info2C room_id}
      |> sd()
    else
      Role.Mod.Role.common_data()
      |> Lobby.Svr.enter()
    end

    :ok
  end

  def h(_state, %Lobby.Heart2S{}) do
    role_id() |> Lobby.Svr.heart()
  end

  def h(~M{%__MODULE_ room_id} = state, ~M{%Lobby.CreatRoom2S type, member_cap,password}) do
    if room_id == 0 do
      {:ok, room_id} = Lobby.Svr.create_room(role_id(), type, member_cap, password)
      {:ok, ~M{state| room_id}}
    else
      sd_err(0, "已经在房间里了")
    end
  end

  def on_offline(_state) do
    role_id() |> Lobby.Svr.offline()
  end
end
