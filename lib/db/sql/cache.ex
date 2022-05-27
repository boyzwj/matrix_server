defmodule DB.SQL.LocalCache do
  use Nebulex.Cache,
    otp_app: :matrix_server,
    adapter: Nebulex.Adapters.Local
end
