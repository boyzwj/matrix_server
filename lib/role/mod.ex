defmodule Role.Mod do
  defmacro __using__(opts) do
    opts = Macro.expand(opts, __CALLER__)

    quote do
      use Memento.Table, unquote(opts)
      use Common

      def load() do
        DBA.dirty_read(__MODULE__, Role.RoleSvr.role_id())
      end

      def init() do
        load() |> init()
      end

      defp init(_args) do
        raise "#{__MODULE__}, init not implemented"
      end

      def secondloop() do
        get_data() |> secondloop()
      end

      defp secondloop(_arg) do
        :pass
      end

      def on_terminate() do
      end

      def save() do
        get_data() |> save()
      end

      defp save(nil), do: :ok

      defp save(data) do
        if is_dirty() do
          with :ok <- DBA.dirty_write(data) do
            set_dirty(false)
            true
          else
            _ ->
              false
          end
        else
          true
        end
      end

      def get_data() do
        Process.get({__MODULE__, :data})
      end

      def set_data(data) do
        Process.put({__MODULE__, :data}, data)
      end

      def set_dirty(dirty?) do
        Process.put({__MODULE__, :dirty}, dirty?)
      end

      def is_dirty() do
        Process.get({__MODULE__, :dirty}, false)
      end

      defoverridable init: 1, secondloop: 1, on_terminate: 0, save: 1
    end
  end
end
