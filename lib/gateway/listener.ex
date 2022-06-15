defmodule GateWay.GameListener do
  def child_spec(opts) do
    :ranch.child_spec(__MODULE__, :ranch_tcp, opts, GateWay.Session, [])
  end
end
