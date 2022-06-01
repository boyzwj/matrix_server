defmodule Role.Mod.System do
  use Role.Mod

  use Memento.Table,
    attributes: [:id, :last_ping, :update_at],
    type: :set
end
