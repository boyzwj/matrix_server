defmodule Robot.Worker do
  defstruct id: nil,
            socket: nil,
            status: 0,
            role_id: 0,
            session_id: nil,
            crypto_key: nil,
            last_recv_index: 0,
            last_send_index: 0,
            recv_buffer: <<>>

  use GenServer
  use Common

  ### =================== API =======================

  def child_spec(opts) do
    worker_id = Keyword.fetch!(opts, :worker_id)

    %{
      id: "#{__MODULE__}_#{worker_id}",
      start: {__MODULE__, :start_link, [worker_id]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, [worker_id], name: via_tuple(worker_id))
  end

  @impl true
  def init([worker_id]) do
    Logger.debug("Robot #{worker_id}  started")
    Process.send_after(self(), :loop, 500)
    {:ok, %Robot.Worker{id: worker_id}}
  end

  ### ================== CALLBACK ==================
  @impl true
  def handle_info(:loop, state) do
    Logger.debug("loop")
    state = Robot.FSM.loop(state)
    Process.send_after(self(), :loop, 500)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, ~M{recv_buffer} = state) do
    state = state |> decode(recv_buffer <> data)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug("receive msg #{inspect(msg)}")
    {:noreply, state}
  end

  def via_tuple(worker_id) do
    :"robot_#{worker_id}"
  end

  defp decode(state, <<len::16-little, data::binary-size(len), left::binary>>) do
    state |> Robot.FSM.decode_body(data) |> decode(left)
  end

  defp decode(state, recv_buffer), do: ~M{state | recv_buffer}
end
