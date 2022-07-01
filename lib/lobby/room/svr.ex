defmodule Lobby.Room.Svr do
  use GenServer
  use Common
  @loop_interval 10_000

  def pid(room_id) do
    :global.whereis_name(name(room_id))
  end

  def name(room_id) do
    :"Room_#{room_id}"
  end

  def via(room_id) do
    {:global, name(room_id)}
    # {:via, Horde.Registry, {Matrix.RoleRegistry, role_id}}
  end

  def child_spec(~M{room_id} = args) do
    %{
      id: "Room_#{room_id}",
      start: {__MODULE__, :start_link, [args]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(~M{room_id} = args) do
    GenServer.start_link(__MODULE__, args, name: via(room_id))
  end

  @impl true
  def init(~M{room_id, role_id, type, member_cap, password}) do
    Logger.debug("Room.Svr [#{room_id}]  start")
    :pg.join(__MODULE__, self())
    create_time = Util.unixtime()
    state = ~M{%Lobby.Room  room_id,type,member_cap,password,create_time,owner: role_id}
    :ets.insert(Room, {room_id, state})
    Process.send_after(self(), :secondloop, @loop_interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:secondloop, state) do
    Process.send_after(self(), :secondloop, @loop_interval)
    state = Lobby.Room.secondloop(state)
    {:noreply, state}
  end

  def handle_info(:shutdown, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_reason, ~M{room_id} = _state) do
    :ets.delete(Room, room_id)
    :ok
  end
end
