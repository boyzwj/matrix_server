defmodule Dc.Manager do
  use GenServer
  use Common

  def start_game(args) do
    {func, _} = __ENV__.function
    call({func, args})
  end

  @loop_interval 1000
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :secondloop, @loop_interval)
    :pg.join(__MODULE__, self())
    state = Dc.init()
    {:ok, state}
  end

  def cast(msg) do
    :pg.get_members(__MODULE__)
    |> Enum.each(&GenServer.cast(&1, msg))
  end

  def call(msg) do
    :pg.get_local_members(__MODULE__)
    |> Util.rand_list()
    |> GenServer.call(msg)
  end

  @impl true
  def handle_call({func, arg}, _from, %Dc{} = state) do
    try do
      {reply, state} = apply(Dc, func, [state, arg])
      {:reply, reply, state}
    catch
      error ->
        {:reply, {:error, error}, state}
    end
  end

  @impl true

  def handle_cast({:msg, from, msg}, state) do
    state = Dc.h(state, from, msg)
    {:noreply, state}
  end

  def handle_cast({:dsa_offline, id}, state) do
    state = Dc.dsa_offline(state, id)
    {:noreply, state}
  end

  def handle_cast(msg, state) do
    Logger.warn("unhandle cast : #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true

  def handle_info(:secondloop, %Dc{} = state) do
    Process.send_after(self(), :secondloop, @loop_interval)
    now = Util.unixtime()
    state = ~M{state| now} |> Dc.secondloop()
    {:noreply, state}
  end

  def handle_info(msg, %Dc{} = state) do
    Logger.warn("unhandle info : #{msg}")
    {:noreply, state}
  end

  @impl true
  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def test_battle() do
    start_game([
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
