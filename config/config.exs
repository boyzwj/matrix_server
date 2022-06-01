import Config

import_config "#{config_env()}.exs"

config :matrix_server,
  mix_env: Mix.env(),
  ecto_repos: [DB.Repo]

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'
