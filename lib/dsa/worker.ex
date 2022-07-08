defmodule Dsa.Worker do
  defstruct battle_id: nil,
            room_id: nil,
            map_id: nil,
            role_ids: [],
            ip: nil,
            port: nil,
            pid: nil,
            ref: nil

  use Common
  use GenServer

  @moduledoc """
  ./ds -game_mapId <mapid> -direct_test 1 -playerCnt 10 -game_battleid <battleId>  -net_inPort <inPort>  -net_outPort <outPort> -room_id <room_id>
  """

  alias __MODULE__, as: M

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

  @impl true
  def init([battle_id, room_id, map_id, role_ids, ip, port]) do
    args = []
    args = ["-game_mapId #{map_id}" | args]
    args = ["-direct_test 1" | args]
    args = ["-game_battleid #{battle_id}" | args]
    args = ["-net_outPort #{port}" | args]
    args = ["-room_id #{room_id}" | args]
    {pid, ref} = Process.spawn(fn -> System.cmd("/ds/ds", args) end, [:monitor])

    for role_id <- role_ids do
      Role.Misc.send_to(~M{%Room.StartGame2C battle_id, ip, port,map_id}, role_id)
    end

    state = ~M{%M battle_id,room_id, map_id, role_ids, ip, port,pid, ref}
    {:ok, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid}, ~M{%M ref,battle_id} = state) do
    Dsa.Svr.end_game([battle_id])
    {:stop, :normal, state}
  end

  def cast(battle_id, msg) when is_integer(battle_id) do
    with pid when is_pid(pid) <- name(battle_id) |> :global.whereis_name() do
      cast(pid, msg)
    else
      _ ->
        {:error, :room_not_exist}
    end
  end

  def cast(pid, msg) when is_pid(pid) do
    pid |> GenServer.cast(msg)
  end

  def call(battle_id, msg) when is_integer(battle_id) do
    with pid when is_pid(pid) <- name(battle_id) |> :global.whereis_name() do
      call(pid, msg)
    else
      _ ->
        {:error, :battle_not_exist}
    end
  end

  def call(pid, msg) when is_pid(pid) do
    pid |> GenServer.call(msg)
  end
end
