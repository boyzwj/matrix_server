defmodule Dsa.Worker do
  defstruct battle_id: nil,
            socket: nil,
            room_id: nil,
            map_id: nil,
            positions: %{},
            ready_states: %{},
            host: nil,
            out_port: nil,
            in_port: nil,
            pid: nil,
            os_pid: nil,
            ref: nil,
            ds_path: nil

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
  def init([battle_id, socket, room_id, map_id, positions, host, out_port]) do
    game_mapId = map_id
    direct_test = 0
    game_battleid = battle_id
    net_outPort = out_port
    net_inPort = out_port + 1
    net_dsaPort = 20081
    user_name = System.shell("echo $USER") |> elem(0) |> String.replace("\n", "")

    args =
      for {k, v} <- ~m{game_mapId,direct_test,game_battleid,net_outPort,net_inPort,net_dsaPort} do
        ["-#{k}", "#{v}"]
      end
      |> Enum.concat()

    # Logger.info(args)

    {pid, ref} =
      Process.spawn(
        fn ->
          System.cmd("/home/#{user_name}/ds_2022_07_18_1428/ds", args)
        end,
        [:monitor]
      )

    ready_states =
      for {_, v} <- positions, v != nil, into: %{} do
        {v, false}
      end

    state =
      ~M{%M battle_id,socket,room_id, map_id, positions,ready_states, host, out_port,in_port: net_inPort,pid, ref}

    {:ok, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, ~M{%M ref,battle_id} = state) do
    Dsa.Svr.end_game([battle_id])
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:msg, msg}, state) do
    state = handle(state, msg)
    {:noreply, state}
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

  def handle(state, ~M{%Dsa.Start2S pid,result} = msg) do
    Logger.warn("receive #{inspect(msg)}")

    if result == 0 do
      Logger.debug("the battle os pid is #{pid}")
      ~M{%M state| os_pid: pid}
    else
      Logger.warning("battle start fail!")
      state
    end
  end

  def handle(~M{%M } = state, ~M{%Dsa.BattleInfo2S battle_id} = msg) do
    Logger.debug("receive #{inspect(msg)}")

    battle_info = %Dsa.BattleInfo{
      auto_armor: true,
      kill_award_double: false,
      init_hp: 100,
      max_hp: 100,
      gravity_rate: 1,
      friction_rate: 1,
      head_shoot_only: false,
      stat_trak: false,
      game_level: 1,
      win_type: :kills,
      win_value: 50
    }

    state
    |> send2ds(~M{%Dsa.BattleInfo2C battle_id,battle_info})
    |> send_role_info()
  end

  def handle(~M{%M ready_states} = state, ~M{%Dsa.RoleReady2S player_id}) do
    ready_states = Map.put(ready_states, player_id, true)
    ~M{state| ready_states} |> check_start()
  end

  def handle(
        state,
        ~M{%Dsa.Heartbeat2S battle_id,pid,defender_score,attacker_score,online_players} = msg
      ) do
    Logger.warn("receive #{inspect(msg)}")
    state
  end

  def handle(state, ~M{%Dsa.PlayerQuit2S battle_id, player_id,reason} = msg) do
    Logger.warn("receive #{inspect(msg)}")
    state
  end

  def handle(state, msg) do
    Logger.warn("unhandle dsa msg #{inspect(msg)}")
    state
  end

  defp send2ds(~M{%M socket,in_port} = state, msg) do
    :ok = :gen_udp.send(socket, {127, 0, 0, 1}, in_port, Dsa.Pb.encode!(msg))
    # :ok = :gen_udp.send(socket, {127, 0, 0, 1}, 20081, Dsa.Pb.encode!(msg))
    state
  end

  defp send_role_info(~M{%M positions} = state) do
    positions
    |> Enum.each(fn {pos, id} ->
      if id != nil do
        {_, ~M{%Common.RoleInfo role_name,level,avatar_id}} = Role.Mod.Role.role_info(id)

        camp_id =
          cond do
            # T
            pos in [1, 2, 3, 4, 5] -> 1
            # CT
            pos in [6, 7, 8, 9, 10] -> 2
            # Observer
            true -> 8
          end

        base_info = %Dsa.RoleBaseInfo{
          uid: id,
          name: role_name,
          group_id: 1,
          camp_id: camp_id,
          avatar: avatar_id,
          level: level
        }

        role = %Dsa.Role{
          replace_uid: id,
          ai_property_type: 1,
          robot: 0,
          robot_type: 0,
          base_info: base_info
        }

        send2ds(state, %Dsa.RoleInfo2C{role: role})
      end
    end)

    state
  end

  defp check_start(~M{%M room_id,battle_id,out_port,host,map_id,ready_states} = state) do
    if ready_states |> Map.values() |> Enum.all?() do
      Logger.debug("broad cast to room: #{room_id}")

      Lobby.Room.Svr.broad_cast(
        room_id,
        ~M{%Room.StartGame2C battle_id, host, port: out_port,map_id}
      )
    end

    state
  end
end
