defmodule Dc.Listener do
  def child_spec(opts) do
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, Dc.Svr, [])
  end
end
