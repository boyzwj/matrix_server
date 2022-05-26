defmodule Common do
  defmacro __using__(_) do
    quote do
      import ShorterMaps
      require Logger
    end
  end
end
