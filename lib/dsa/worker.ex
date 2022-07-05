defmodule Dsa.Worker do
  defstruct map_id: nil,
            mode: nil,
            room_id: nil,
            out_port: nil,
            in_port: nil,
            dsa_port: nil,
            player_cnt: nil,
            direct_test: true

  @moduledoc """
  ./ds -game_mapId <mapid> -direct_test 1 -playerCnt 10 -game_battleid <battleId>  -net_inPort <inPort>  -net_outPort <outPort> -room_id <room_id>
  """

  def pid(battle_id) do
    :global.whereis_name(name(battle_id))
  end

  def name(battle_id) do
    :"Battle_#{battle_id}"
  end

  def via(battle_id) do
    {:global, name(battle_id)}
    # {:via, Horde.Registry, {Matrix.RoleRegistry, role_id}}
  end

  def child_spec([battle_id | _] = args) do
    %{
      id: "Battle_#{battle_id}",
      start: {__MODULE__, :start_link, [args]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link([battle_id | _] = args) do
    GenServer.start_link(__MODULE__, args, name: via(battle_id))
  end
end
