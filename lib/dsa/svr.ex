defmodule Dsa.Svr do
  use GenServer
  use Common
  @loop_interval 1000

  ## ===================  API ==========================

  def start_game(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  def end_game(args) do
    {func, _} = __ENV__.function
    GenServer.call(__MODULE__, {func, args})
  end

  ### =====================callback ======================
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :secondloop, @loop_interval)
    state = Dsa.init()
    {:ok, state}
  end

  @impl true
  def handle_info(:secondloop, %Dsa{} = state) do
    now = Util.unixtime()
    state = ~M{state|now} |> Dsa.secondloop()
    {:noreply, state}
  end

  @impl true

  def handle_call({func, arg}, _from, %Dsa{} = state) do
    try do
      {reply, state} = apply(Dsa, func, [state, arg])
      {:reply, reply, state}
    catch
      error ->
        {:reply, error, state}
    end
  end

  def handle_call(msg, _from, state) do
    Logger.warn("unhandle call : #{msg}")
    reply = :ignore
    {:reply, reply, state}
  end

  @impl true
  def handle_cast({func, arg}, %Dsa{} = state) do
    try do
      state = apply(Dsa, func, [state, arg])
      {:noreply, state}
    catch
      error ->
        Logger.error("handle cast error : #{error}")
        {:noreply, state}
    end
  end

  def handle_cast(msg, state) do
    Logger.warn("unhandle cast : #{msg}")
    {:noreply, state}
  end
end
