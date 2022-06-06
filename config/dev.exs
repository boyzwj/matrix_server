import Config

config :logger, backends: [:console, {LoggerFileBackend, :info}, {LoggerFileBackend, :error_log}]

config :logger, :info,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  path: "./logs/info_#{Date.utc_today()}.MD",
  level: :info

config :logger, :error_log,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  path: "./logs/error_#{Date.utc_today()}.MD",
  level: :error

config :logger, :console,
  format: "### [$date $time] $metadata[$level] \n  * $levelpad$message\n\n",
  metadata: [:module, :function, :line],
  level: :debug

config :matrix_server,
  db_worker_num: 32
