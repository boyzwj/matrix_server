defmodule Lobby.Listener do
  def child_spec(opts) do
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, Lobby.Dsa, [])
  end
end
