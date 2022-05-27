defmodule DB.Repo do
  use Ecto.Repo,
    otp_app: :matrix_server,
    adapter: Ecto.Adapters.MyXQL
end
