defmodule Role.Mod.Room do
  defstruct room_id: 0, mode: 0
  use Role.Mod

  def set_room_id(room_id) do
    with %__MODULE__{} = data <- get_data() do
      set_data(~M{%__MODULE__ data| room_id})
    else
      _ ->
        Logger.warn("role room data is unexpected ...")
    end
  end
end
