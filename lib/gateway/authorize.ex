defmodule Authorize do
  use Common

  def authorize(token) do
    with role_id when is_number(role_id) <- Redis.hget(Service.TokenAccount, token) do
      {:ok, role_id}
    else
      _ ->
        role_id = GID.get_role_id()
        # create_time = Util.unixtime()

        Redis.hset(Service.TokenAccount, token, role_id)
        {:ok, role_id}
    end
  end
end
