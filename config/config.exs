import Config

import_config "#{config_env()}.exs"

config :matrix_server, DB.LocalCache,
  backend: :shards,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 2_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :matrix_server,
  mix_env: Mix.env(),
  ecto_repos: [DB.Repo]
