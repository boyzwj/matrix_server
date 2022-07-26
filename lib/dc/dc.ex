defmodule Dc do
  defstruct dsa_infos: %{}, room_list: %{}, now: nil, sorted_dsa: nil
  use Common
  alias Discord.SortedSet

  def init() do
    sorted_dsa = SortedSet.new()
    %Dc{sorted_dsa: sorted_dsa}
  end

  def secondloop(state) do
    state
  end

  def start_game(~M{%Dc dsa_infos,room_list} = state, [map_id, room_id, members | _]) do
    with {resources_left, dsa_id} when resources_left > 0 <- choose_dsa(state),
         {from, _, _} <- dsa_infos[dsa_id] do
      room_list = Map.put(room_list, room_id, dsa_id)
      members = Map.filter(members, fn {_key, val} -> is_number(val) end)

      infos =
        for {_k, v} <- members, into: %{} do
          {_, ~M{%Pbm.Common.RoleInfo role_name,level,avatar_id}} = Role.Mod.Role.role_info(v)
          {v, ~M{%Dc.RoleInfo role_name,level,avatar_id}}
        end

      Dc.Client.send2dsa(from, %Dc.StartGame2C{
        room_id: room_id,
        map_id: map_id,
        members: members,
        infos: infos
      })

      {:ok, ~M{state| room_list}}
    else
      _ ->
        {:error, :no_dsa_alivable}
    end
  end

  def h(
        ~M{%Dc now,dsa_infos,sorted_dsa} = state,
        from,
        ~M{%Dc.HeartBeat2S id,resources_left}
      ) do
    with {_, _, old_resource_left} <- dsa_infos[id] do
      sorted_dsa
      |> SortedSet.remove({old_resource_left, id})
      |> SortedSet.add({resources_left, id})
    else
      _ ->
        sorted_dsa
        |> SortedSet.add({resources_left, id})
    end

    dsa_infos = dsa_infos |> Map.put(id, {from, now, resources_left})
    # Logger.debug("current dsa_list #{inspect(SortedSet.to_list(sorted_dsa))}")
    ~M{state | dsa_infos}
  end

  def h(~M{%Dc room_list} = state, _from, ~M{%Dc.BattleEnd2S room_id}) do
    room_list = Map.delete(room_list, room_id)
    ~M{state | room_list}
  end

  def h(~M{%Dc } = state, _from, ~M{%Dc.RoomMsg2S room_id,data}) do
    ds_msg = PB.decode!(data)
    IO.inspect(ds_msg)
    Lobby.Room.Svr.cast(room_id, {:ds_msg, ds_msg})
    state
  end

  def dsa_offline(~M{%Dc dsa_infos,sorted_dsa} = state, id) do
    with {{_, _, old_resource_left}, dsa_infos} <- Map.pop(dsa_infos, id) do
      sorted_dsa |> SortedSet.remove({old_resource_left, id})
      # Logger.debug("current dsa_list #{inspect(SortedSet.to_list(sorted_dsa))}")
      # IO.inspect(dsa_infos)
      ~M{state| dsa_infos}
    else
      _ ->
        state
    end
  end

  defp choose_dsa(~M{%Dc sorted_dsa}) do
    size = SortedSet.size(sorted_dsa)

    if size > 0 do
      SortedSet.at(sorted_dsa, size - 1)
    end
  end
end
