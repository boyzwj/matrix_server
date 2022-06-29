defmodule Lobby.Svr do
  use GenServer
  use Common
  @loop_interval 1000

  def enter(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  def heart(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  def offline(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  ### API #####

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :secondloop, @loop_interval)
    {:ok, %Lobby{}}
  end

  @impl true
  def handle_call({func, arg}, _from, %Lobby{} = state) do
    {reply, state} = apply(Lobby, func, [state, arg])
    {:reply, reply, state}
  end

  def handle_call(msg, _from, state) do
    Logger.warn("unhandle call : #{msg}")
    reply = :ignore
    {:reply, reply, state}
  end

  @impl true
  def handle_cast(msg, %Lobby{} = state) do
    Logger.warn("unhandle cast : #{msg}")
    {:noreply, state}
  end

  @impl true

  def handle_info(:secondloop, %Lobby{} = state) do
    now = Util.unixtime()
    state = ~M{state|now} |> Lobby.secondloop()
    {:noreply, state}
  end

  def handle_info(msg, %Lobby{} = state) do
    Logger.warn("unhandle info : #{msg}")
    {:noreply, state}
  end

  @impl true
  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end
end
