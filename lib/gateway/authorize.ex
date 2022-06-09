defmodule Authorize do
  use Common

  def authorize(token) do
    with %Service.TokenAccount{role_id: role_id} <- DBA.read(Service.TokenAccount, token) do
      {:ok, role_id}
    else
      _ ->
        role_id = GID.get_role_id()
        create_time = Util.unixtime()

        ~M{%Service.TokenAccount role_id, token,create_time}
        |> DBA.write()

        {:ok, role_id}
    end
  end
end
