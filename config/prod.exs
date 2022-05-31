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

config :matrix_server, DB.Repo,
  hostname: "{{db_host}}",
  port: "{{db_port}}",
  database: "{{db_name}}",
  username: "{{db_user}}",
  password: "{{db_pass}}",
  ssl: false,
  show_sensitive_data_on_connection_error: true

config :libcluster,
  topologies: [
    matrix: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [
          :"gate_1@127.0.01",
          :"lobby_1@127.0.0.1",
          :"db_1@127.0.0.1",
          :"db_2@127.0.0.1"
        ]
      ]
    ]
  ]
