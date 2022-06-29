defmodule Lobby do
  defstruct roles: %{},
            rooms: %{},
            role_num: 0,
            last_heart: %{},
            now: 0

  use Common
  use PipeTo.Override

  @heart_timeout 10_000
  @doc """
  玩家进入游戏大厅
  """
  def enter(
        ~M{%__MODULE__ roles} = state,
        ~M{role_id} = role_info
      ) do
    with nil <- roles |> Map.get(role_id, nil) do
      roles = roles |> Map.put(role_id, role_info)

      ~M{state| roles}
      |> update_in([:role_num], &(&1 + 1))
      |> set_last_heart(role_id)
      |> send_lobby_info(role_id)
      |> ok()
    else
      _ ->
        roles = roles |> Map.put(role_id, role_info)

        ~M{state| roles}
        |> set_last_heart(role_id)
        |> send_lobby_info(role_id)
        |> ok()
    end
  end

  @doc """
  大厅每秒循环，踢掉超时玩家
  """

  def secondloop(~M{%__MODULE__ now,last_heart} = state) do
    for {role_id, last_heart_time} <- last_heart, last_heart_time + @heart_timeout < now do
      role_id
    end
    ~> kick_roles(state, _)
  end

  @doc """
  玩家大厅订阅心跳
  """
  def heart(~M{%__MODULE__ now,roles,last_heart} = state, role_id) do
    if Map.has_key?(roles, role_id) do
      last_heart = Map.put(last_heart, role_id, now)
      {:ok, ~M{state| last_heart}}
    else
      {:error, state}
    end
  end

  @doc """
  玩家退出大厅
  """
  def offline(state, role_id) do
    do_kick_role(state, role_id)
    |> ok
  end

  defp send_lobby_info(~M{%__MODULE__ rooms,role_num} = state, role_id) do
    ~M{%Lobby.Info2C rooms, role_num} |> Role.Misc.send_to(role_id)
    state
  end

  defp set_last_heart(~M{%__MODULE__ last_heart, now} = state, role_id) do
    last_heart = Map.put(last_heart, role_id, now)
    ~M{state| last_heart}
  end

  defp kick_roles(state, []) do
    state
  end

  defp kick_roles(state, [role_id | t]) do
    state
    |> do_kick_role(role_id)
    |> kick_roles(t)
  end

  defp do_kick_role(~M{%__MODULE__ roles,role_num,last_heart} = state, role_id) do
    roles = Map.delete(roles, role_id)
    last_heart = Map.delete(last_heart, role_id)
    role_num = role_num - 1
    ~M{state |  roles,role_num,last_heart}
  end

  defp ok(state), do: {:ok, state}
end
