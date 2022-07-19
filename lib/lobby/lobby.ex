defmodule Lobby do
  defstruct now: 0

  use Common
  use PipeTo.Override

  alias __MODULE__, as: M

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

  def secondloop(~M{%M } = state) do
    state
  end

  @doc """
  创建房间
  """
  def create_room(
        ~M{%M  } = state,
        args
      ) do
    {:ok, room_id} = make_room_id()
    args = [room_id | args]

    with {:ok, _pid} <- DynamicSupervisor.start_child(Room.Sup, {Lobby.Room.Svr, args}) do
      {{:ok, room_id}, state}
    else
      _ ->
        recycle_room_id(room_id)
        throw("房间创建失败")
    end
  end

  def get_room_list(~M{%M } = state, [role_id, select_map_id]) do
    f = fn {_, ~M{%Lobby.Room map_id} = data}, acc ->
      if select_map_id == 0 || select_map_id == map_id do
        [Lobby.Room.to_common(data) | acc]
      else
        acc
      end
    end

    rooms = :ets.foldl(f, [], Room)
    ~M{%Pbm.Room.List2C rooms} |> Role.Misc.send_to(role_id)
    state |> ok()
  end

  def get_room_info(state, room_id) do
    with [{_, v}] <- :ets.lookup(Room, room_id) do
      {v, state}
    else
      _ ->
        {nil, state}
    end
  end

  def recycle_room(state, room_id) do
    recycle_room_id(room_id)
    state |> ok()
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

  defp recycle_room_id(room_id) do
    {id_start, pool} = Process.get({__MODULE__, :room_id_pool})
    pool = LimitedQueue.push(pool, room_id)
    Process.put({__MODULE__, :room_id_pool}, {id_start, pool})
  end
end
