defmodule Role.Mod do
  defmacro __using__(opts) do
    opts = Macro.expand(opts, __CALLER__)

    quote do
      use Memento.Table, unquote(opts)
      use Common

      def load() do
        DBA.dirty_read(__MODULE__, RoleSvr.role_id())
      end

      def init() do
        data = load()

        if data == nil do
          RoleSvr.role_id()
          |> on_first_init()
          |> on_init()
          |> set_data()
        else
          on_init(data)
          |> set_data()
        end
      end

      defp on_init(data) do
        data
      end

      defp on_first_init(id) do
        %__MODULE__{id: id}
      end

      def h(msg) do
        with %__MODULE__{} = data <- get_data() |> h(msg) do
          set_data(data)
        else
          error ->
            Logger.warn("handle msg:#{inspect(msg)} has illigal return: #{inspect(error)}")
        end
      end

      defp h(data, msg) do
        Logger.warn("unhandle msg: #{inspect(msg)} ")
      end

      def secondloop(now) do
        get_data() |> secondloop(now)
      end

      defp secondloop(_data, _now) do
        :pass
      end

      def on_offline() do
        get_data() |> on_offline()
      end

      defp on_offline(data) do
        data
      end

      def on_terminate() do
        get_data() |> on_terminate()
      end

      def on_terminate(data) do
        data
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
        set_dirty(true)
      end

      def set_dirty(dirty?) do
        Process.put({__MODULE__, :dirty}, dirty?)
      end

      def is_dirty() do
        Process.get({__MODULE__, :dirty}, false)
      end

      defoverridable on_first_init: 1,
                     on_init: 1,
                     h: 2,
                     secondloop: 2,
                     on_offline: 1,
                     on_terminate: 1,
                     save: 1
    end
  end
end
