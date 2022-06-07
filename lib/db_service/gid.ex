defmodule GID do
  use GenServer
  require Logger
  defstruct block_id: nil
  @role_id_seed 10_000_000_000

  # API
  def get_role_id() do
    GenServer.call(GID, {:get, :role_id})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(args) do
    block_id = Keyword.get(args, :block_id, 1)
    Logger.debug("block: #{block_id} GID start")
    {:ok, %GID{block_id: block_id}}
  end

  @impl true
  def handle_call({:get, key}, _from, %GID{block_id: block_id} = state) do
    value = :mnesia.dirty_update_counter(GID, {key, block_id}, 1)
    reply = @role_id_seed * block_id + value
    {:reply, reply, state}
  end
end
