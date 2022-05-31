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

config :matrix_server, DB.Repo,
  database: "matrix",
  username: "root",
  password: "123456",
  hostname: "localhost",
  port: 3306,
  ssl: false,
  show_sensitive_data_on_connection_error: true