defmodule Dsa do
  use Common
  @port_range [30_001, 40_000]

  defstruct socket: nil, resources: nil, workers: %{}, now: nil

  def init() do
    [min, max] = @port_range
    host = "192.168.15.101"

    resources =
      :lists.seq(min, max, 2)
      |> Enum.reduce(LimitedQueue.new(20_000), fn port, acc ->
        LimitedQueue.push(acc, {host, port})
      end)

    opts = [inet_backend: :inet, active: true] ++ [:binary]
    {:ok, socket} = :gen_udp.open(20081, opts)
    %Dsa{socket: socket, resources: resources, now: Util.unixtime()}
  end

  def secondloop(state) do
    state
  end

  def start_game(~M{%Dsa workers,socket} = state, [map_id, room_id, positions] = args) do
    Logger.debug("start game, args: #{inspect(args)}")

    with {:ok, state, {host, port}} <- get_resource(state) do
      battle_id = GID.get_battle_id()
      args = [battle_id, socket, room_id, map_id, positions, host, port]
      {:ok, worker_pid} = DynamicSupervisor.start_child(Dsa.Worker.Sup, {Dsa.Worker, args})
      now = Util.unixtime()
      workers = workers |> Map.put(battle_id, ~M{worker_pid, room_id, now})
      {:ok, ~M{state| workers}}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def end_game(~M{%Dsa workers} = state, [battle_id]) do
    Logger.debug("game end battle_id : #{battle_id}")

    with ~M{host, port} <- Map.get(workers, battle_id) do
      state = recycle_resource(state, {host, port})
      {:ok, state}
    else
      _ ->
        {:ok, state}
    end
  end

  def handle(~M{%Dsa workers } = state, ~M{battle_id} = msg) do
    with ~M{worker_pid} <- workers[battle_id] do
      GenServer.cast(worker_pid, {:msg, msg})
    else
      _ ->
        Logger.warn("receive unexpected msg : #{inspect(msg)}")
    end

    state
  end

  def handle(state, msg) do
    Logger.warn("unhandle dsa msg #{inspect(msg)}")
    state
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

  def test_battle() do
    Dsa.Svr.start_game([
      10_051_068,
      1,
      %{
        1 => 100_000_001,
        2 => 100_000_002,
        3 => 100_000_003,
        4 => nil,
        6 => 100_000_006,
        7 => 100_000_007
      }
    ])
  end
end
