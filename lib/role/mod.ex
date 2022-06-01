defmodule Role.Mod do
  defmacro __using__(opts) do
    opts = Macro.expand(opts, __CALLER__)

    quote do
      use Memento.Table, unquote(opts)
      use Common

      def init() do
        raise "#{__MODULE__}, init not implemented"
      end

      def secondloop() do
      end

      def on_terminate() do
      end

      def save() do
        get_data() |> save()
      end

      defp save(nil), do: :ok

      defp save(data), do: :ok

      def get_data() do
        Process.get({__MODULE__, :data})
      end

      def set_data(data) do
        Process.put({__MODULE__, :data}, data)
      end

      defoverridable init: 0, secondloop: 0, on_terminate: 0, save: 1
    end
  end
end
