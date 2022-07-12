defmodule Dsa do
  use Common
  @port_range [30_001, 40_000]

  defstruct resources: nil, workers: %{}, now: nil

  def init() do
    [min, max] = @port_range
    host = "192.168.15.101"

    resources =
      :lists.seq(min, max, 2)
      |> Enum.reduce(LimitedQueue.new(20_000), fn port, acc ->
        LimitedQueue.push(acc, {host, port})
      end)

    %Dsa{resources: resources, now: Util.unixtime()}
  end

  def secondloop(state) do
    state
  end

  def start_game(~M{%Dsa workers} = state, [map_id, room_id, role_ids] = args) do
    Logger.debug("start game, args: #{inspect(args)}")

    with {:ok, state, {host, port}} <- get_resource(state) do
      battle_id = GID.get_battle_id()
      args = [battle_id, room_id, map_id, role_ids, host, port]
      {:ok, pid} = DynamicSupervisor.start_child(Dsa.Worker.Sup, {Dsa.Worker, args})
      now = Util.unixtime()
      workers = workers |> Map.put(battle_id, ~M{map_id, pid, role_ids, host, port, now})
      {:ok, ~M{state| workers}}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def end_game(~M{%Dsa workers} = state, [battle_id]) do
    with ~M{host, port} <- Map.get(workers, battle_id) do
      state = recycle_resource(state, {host, port})
      {:ok, state}
    else
      _ ->
        {:ok, state}
    end
  end

  defp get_resource(~M{%Dsa resources} = state) do
    with {:ok, resources, res} <- LimitedQueue.pop(resources) do
      {:ok, ~M{state| resources}, res}
    else
      _ ->
        {:error, :resource_used_out}
    end
  end

  defp recycle_resource(~M{%Dsa resources} = state, res) do
    resources = LimitedQueue.push(resources, res)
    ~M{state| resources}
  end
end
