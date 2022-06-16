import Config

config :logger, backends: [:console, {LoggerFileBackend, :info}, {LoggerFileBackend, :error_log}]

config :logger, :info,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  path: "{{root}}/logs/info_#{Date.utc_today()}.MD",
  level: :info

config :logger, :error_log,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  path: "{{root}}/logs/error_#{Date.utc_today()}.MD",
  level: :error

config :logger, :console,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  level: :debug

config :matrix_server,
  db_worker_num: 32,
  role_interface_num: 16,
  redis_blocks: [
    {"127.0.0.1", 6379},
    {"127.0.0.1", 6380},
    {"127.0.0.1", 6381},
    {"127.0.0.1", 6382}
  ],
  topologies: [
    game_server: [
      strategy: Cluster.Strategy.Gossip
    ]
  ]
