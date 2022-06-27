defmodule Role.Mod.Room do
  defstruct status: 0
  use Role.Mod

  def save(_state), do: true
end
