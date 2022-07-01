defmodule Api.Api do
  use Plug.Router
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "hello" do
    conn
    |> put_resp_content_type("text/json")
    |> send_resp(200, Jason.encode!(%{msg: "锄禾日当午"}))
  end
end
