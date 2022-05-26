defmodule DB.Repo do
  use Ecto.Repo,
    otp_app: :server,
    adapter: Ecto.Adapters.MyXQL
end
