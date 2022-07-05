defmodule Lobby do
  defstruct now: 0

  use Common
  use PipeTo.Override

  def init() do
    queue = LimitedQueue.new(10_000)
    queue = 1001..2000 |> Enum.reduce(queue, &LimitedQueue.push(&2, &1))
    id_start = 2001
    Process.put({__MODULE__, :room_id_pool}, {id_start, queue})
    %Lobby{}
  end

  @doc """
  大厅每秒循环，踢掉超时玩家
  """

  def secondloop(~M{%__MODULE__ } = state) do
    state
  end

  @doc """
  创建房间
  """
  def create_room(
        ~M{%__MODULE__  } = state,
        ~M{role_id,type,member_cap,password}
      ) do
    {:ok, room_id} = make_room_id()
    start_room(room_id, role_id, type, member_cap, password)
    {{:ok, room_id}, state}
  end

  defp send_rooms_info(~M{%__MODULE__  } = state, role_id) do
    f = fn {_, %Lobby.Room{} = data}, acc ->
      [Lobby.Room.to_common(data) | acc]
    end

    rooms = :ets.foldl(f, [], Room)
    ~M{%Room.List2C rooms} |> Role.Misc.send_to(role_id)
    state
  end

  defp start_room(room_id, role_id, type, member_cap, password) do
    DynamicSupervisor.start_child(
      Room.Sup,
      {Lobby.Room.Svr, [room_id, role_id, type, member_cap, password]}
    )
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
