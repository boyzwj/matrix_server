defmodule Api.Router do
  use Plug.Router
  use Common
  plug(:match)
  plug(:dispatch)

  forward("/ctl", to: Api.Ctl)

  forward("/api", to: Api.Api)

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Oops!")
  end
end
