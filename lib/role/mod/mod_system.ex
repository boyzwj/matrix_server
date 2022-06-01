defmodule Role.Mod.System do
  use Role.Mod,
    attributes: [:id, :last_ping, :update_at],
    type: :set
end
