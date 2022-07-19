defmodule Lobby.Dsa do
  use GenServer
  use Common
  alias Lobby.Dsa

  defstruct socket: nil,
            transport: nil,
            session_id: nil,
            dsa_id: nil,
            status: 0,
            last_heart: 0,
            recv_buffer: <<>>,
            send_buffer: []

  @behaviour :ranch_protocol
  @timeout 5000

  @status_unauthorized 0
  @status_authorized 1

  @impl true
  def start_link(ref, transport, opts) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :init, [{ref, transport, opts}])}
  end

  @impl true
  def init({ref, transport, _opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: :once)
    session_id = UUID.uuid1()
    status = @status_unauthorized

    state = %__MODULE__{
      socket: socket,
      transport: transport,
      session_id: session_id,
      status: status
    }

    :gen_server.enter_loop(__MODULE__, [], state, @timeout)
  end

  @impl true
  def handle_info({:tcp, socket, data}, ~M{socket,transport,recv_buffer} = state) do
    # state = state |> decode(recv_buffer <> data)
    :ok = transport.setopts(socket, active: :once)
    {:noreply, state, @timeout}
  end
end
