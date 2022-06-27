defmodule Role.Mod do
  defmacro __using__(_opts) do
    quote do
      use Common

      def load() do
        data = Redis.hget(Role.Misc.dbkey(), __MODULE__)
        data && Poison.decode!(data, as: %__MODULE__{})
      end

      def init() do
        data = get_data()

        if data == nil do
          Role.Svr.role_id()
          |> on_first_init()
          |> on_init()
          |> set_data()
        else
          on_init(data)
          |> set_data()
        end
      end

      defp on_init(data) do
        data || %__MODULE__{}
      end

      defp on_first_init(_id) do
        IO.inspect("first init")
        %__MODULE__{}
      end

      def h(msg) do
        with {:ok, %__MODULE__{} = data} <- get_data() |> h(msg) do
          set_data(data)
        else
          :ok ->
            :ignore

          :ignore ->
            :ignore

          error ->
            Logger.warn(
              "handle msg:#{inspect(msg)} has illigal return: #{inspect(error)}, expect end with {:ok, newstate}, :ok , :ignore"
            )
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
        with true <- dirty?(),
             data <- Map.from_struct(data),
             v when is_integer(v) <- Redis.hset(Role.Misc.dbkey(), __MODULE__, data) do
          set_dirty(false)
          true
        else
          false ->
            true

          _ ->
            false
        end
      end

      @spec get_data() :: term
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

      def dirty?() do
        Process.get({__MODULE__, :dirty}, false)
      end

      def role_id() do
        Process.get(:role_id)
      end

      def sd(msg) do
        sid = Process.get(:sid)
        Role.Misc.send_to(sid, msg)
      end

      def sd_err(error_code, error_msg \\ nil) do
        sid = Process.get(:sid)
        msg = %System.Error2C{error_code: error_code, error_msg: error_msg}
        Role.Misc.send_to(sid, msg)
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
