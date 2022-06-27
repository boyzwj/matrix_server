defmodule Role.Mod do
  @moduledoc """
  角色协议回调模块宏,实现了上线加载，初始化，协议处理以及下线保存的回调，支持OVERRIDE重写
  """
  defmacro __using__(_opts) do
    quote do
      use Common

      @doc """
      上线从Redis加载角色数据
      """
      def load() do
        data = Redis.hget(Role.Misc.dbkey(), __MODULE__)
        data && Poison.decode!(data, as: %__MODULE__{})
      end

      @doc """
      上线初始化角色数据
      """
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
        %__MODULE__{}
      end

      @doc """
      协议处理宏
      """
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

      @doc """
      每秒循环宏
      """
      def secondloop(now) do
        get_data() |> secondloop(now)
      end

      defp secondloop(_data, _now) do
        :pass
      end

      @doc """
      下线接口
      """
      def on_offline() do
        get_data() |> on_offline()
      end

      defp on_offline(data) do
        data
      end

      @doc """
      进程结束接口
      """
      def on_terminate() do
        get_data() |> on_terminate()
      end

      def on_terminate(data) do
        data
      end

      @doc """
      存档接口
      """
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

      @doc """
      读取模块数据
      """
      @spec get_data() :: term
      def get_data() do
        Process.get({__MODULE__, :data})
      end

      @doc """
      报错模块数据
      """
      def set_data(data) do
        Process.put({__MODULE__, :data}, data)
        set_dirty(true)
      end

      defp set_dirty(dirty?) do
        Process.put({__MODULE__, :dirty}, dirty?)
      end

      @doc """
      模块数据是否为'脏',脏数据会被同步到数据库
      """
      def dirty?() do
        Process.get({__MODULE__, :dirty}, false)
      end

      @doc """
      获取本进程角色ID
      """
      def role_id() do
        Process.get(:role_id)
      end

      @doc """
      进程内协议发送接口
      """
      def sd(msg) do
        sid = Process.get(:sid)
        Role.Misc.send_to(sid, msg)
      end

      @doc """
      进程内错误码发送接口
      """
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
