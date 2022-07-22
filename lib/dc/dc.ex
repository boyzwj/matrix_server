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

      Dc.Client.send2dsa(from, %Dc.StartGame2C{room_id: room_id, map_id: map_id, members: members})

      {:ok, ~M{state| room_list}}
    else
      _ ->
        {:error, :no_dsa_alivable}
    end
  end

  def h(
        ~M{%Dc now,dsa_infos,sorted_dsa} = state,
        from,
        ~M{%Dc.HeartBeat2S id,resources_left} = msg
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
    Dc.Client.send2dsa(from, msg)
    ~M{state | dsa_infos}
  end

  defp choose_dsa(~M{%Dc sorted_dsa}) do
    size = SortedSet.size(sorted_dsa)

    if size > 0 do
      SortedSet.at(sorted_dsa, size - 1)
    end
  end
end
