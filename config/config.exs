import Config

import_config "#{config_env()}.exs"

config :server, DB.LocalCache,
  backend: :shards,
  gc_interval: :timer.hours(12),
  max_size: 1_000_000,
  allocated_memory: 2_000_000_000,
  gc_cleanup_min_timeout: :timer.seconds(10),
  gc_cleanup_max_timeout: :timer.minutes(10)

config :server,
  mix_env: Mix.env(),
  ecto_repos: [DB.Repo]

config :server, SocketHandler,
  port: 3199,
  path: "/ws",
  codec: Riverside.Codec.RawText,
  # don't accept connections if server already has this number of connections
  max_connections: 10000,
  # force to disconnect a connection if the duration passed. if :infinity is set, do nothing.
  max_connection_age: :infinity,
  # disconnect if no event comes on a connection during this duration
  idle_timeout: 120_000,
  # TCP SO_REUSEPORT flag
  reuse_port: false,
  show_debug_logs: false,
  transmission_limit: [
    # if 50 frames are sent on a connection
    capacity: 50,
    # in 2 seconds, disconnect it.
    duration: 2000
  ],
  cowboy_opts: [
    # ...
  ]
