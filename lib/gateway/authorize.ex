defmodule Authorize do
  def authorize(token) do
    data = Redis.get("account:#{token}")

    if data do
      Jason.decode(data)
    else
      role_id = GID.get_role_id()
      Redis.set("account:#{token}", role_id)
      dbkey = Role.Misc.dbkey(role_id)
      Redis.hset(dbkey, Role.Mod.Role, %{account: token, role_name: token})
      {:ok, role_id}
    end
  end
end
