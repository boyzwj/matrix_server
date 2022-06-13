defmodule Authorize do
  def authorize(token) do
    data = Redis.get("account:#{token}")

    if data do
      Jason.decode(data)
    else
      role_id = GID.get_role_id()
      Redis.set("accout:#{token}", role_id)
      {:ok, role_id}
    end
  end
end
