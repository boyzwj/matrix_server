defmodule Api.Static do
  use Plug.Builder

  plug(
    Plug.Static,
    at: "/",
    from: {:matrix_server, "priv/static"}
  )

  plug(:not_found)

  def not_found(conn, _) do
    send_resp(conn, 404, "static resource not found")
  end
end
