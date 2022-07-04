defmodule Lobby do
  defstruct roles: %{},
            last_heart: %{},
            now: 0

  use Common
  use PipeTo.Override

  @heart_timeout 10_000

  def init() do
    queue = LimitedQueue.new(10_000)
    queue = 1001..2000 |> Enum.reduce(queue, &LimitedQueue.push(&2, &1))
    id_start = 2001
    Process.put({__MODULE__, :room_id_pool}, {id_start, queue})
    %Lobby{}
  end

  @doc """
  玩家进入游戏大厅
  """
  def enter(
        ~M{%__MODULE__ roles} = state,
        ~M{role_id} = role_info
      ) do
    with nil <- roles |> Map.get(role_id, nil) do
      roles = roles |> Map.put(role_id, role_info)

      ~M{state| roles}
      |> update_in([:role_num], &(&1 + 1))
      |> set_last_heart(role_id)
      |> send_lobby_info(role_id)
      |> ok()
    else
      _ ->
        roles = roles |> Map.put(role_id, role_info)

        ~M{state| roles}
        |> set_last_heart(role_id)
        |> send_lobby_info(role_id)
        |> ok()
    end
  end

  @doc """
  大厅每秒循环，踢掉超时玩家
  """

  def secondloop(~M{%__MODULE__ now,last_heart} = state) do
    for {role_id, last_heart_time} <- last_heart, last_heart_time + @heart_timeout < now do
      role_id
    end
    ~> kick_roles(state, _)
  end

  @doc """
  玩家大厅订阅心跳
  """
  def heart(~M{%__MODULE__ now,roles,last_heart} = state, role_id) do
    if Map.has_key?(roles, role_id) do
      last_heart = Map.put(last_heart, role_id, now)
      {:ok, ~M{state| last_heart}}
    else
      {:error, state}
    end
  end

  @doc """
  玩家退出大厅
  """
  def offline(state, role_id) do
    do_kick_role(state, role_id)
    |> ok
  end

  @doc """
  创建房间
  """
  def create_room(
        ~M{%__MODULE__  } = state,
        ~M{role_id,type,member_cap,password}
      ) do
    state = do_kick_role(state, role_id)
    {:ok, room_id} = make_room_id()
    start_room(room_id, role_id, type, member_cap, password)
    {{:ok, room_id}, state}
  end

  defp send_lobby_info(~M{%__MODULE__  } = state, role_id) do
    f = fn {_, %Lobby.Room{} = data}, acc ->
      [Lobby.Room.to_common(data) | acc]
    end

    rooms = :ets.foldl(f, [], Room)
    ~M{%Lobby.Info2C rooms } |> Role.Misc.send_to(role_id)
    state
  end

  defp start_room(room_id, role_id, type, member_cap, password) do
    DynamicSupervisor.start_child(
      Room.Sup,
      {Lobby.Room.Svr, [room_id, role_id, type, member_cap, password]}
    )
  end

  defp set_last_heart(~M{%__MODULE__ last_heart, now} = state, role_id) do
    last_heart = Map.put(last_heart, role_id, now)
    ~M{state| last_heart}
  end

  defp kick_roles(state, []) do
    state
  end

  defp kick_roles(state, [role_id | t]) do
    state
    |> do_kick_role(role_id)
    |> kick_roles(t)
  end

  defp do_kick_role(~M{%__MODULE__ roles,last_heart} = state, role_id) do
    roles = Map.delete(roles, role_id)
    last_heart = Map.delete(last_heart, role_id)
    ~M{state |  roles,last_heart}
  end

  defp ok(state), do: {:ok, state}

  defp make_room_id() do
    {id_start, pool} = Process.get({__MODULE__, :room_id_pool})

    with {:ok, pool, room_id} <- LimitedQueue.pop(pool) do
      Process.put({__MODULE__, :room_id_pool}, {id_start, pool})
      Logger.debug("create room #{room_id}")
      {:ok, room_id}
    else
      _ ->
        room_id = id_start
        Process.put({__MODULE__, :room_id_pool}, {id_start + 1, pool})
        {:ok, room_id}
    end
  end
end
