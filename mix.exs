defmodule Server.MixProject do
  use Mix.Project

  def project do
    [
      app: :matrix_server,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Main, []},
      extra_applications: [:logger, :crypto, :sasl, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.1", only: :dev},
      {:uuid, "~> 1.1"},
      {:shorter_maps, "~> 2.2"},
      {:pipe_to, "~> 0.2.1"},
      {:sorted_set_nif, "~> 1.2.0"},
      {:logger_file_backend, "~> 0.0.13"},
      {:worker_pool, "~> 6.0"},
      {:protox, "~> 1.6"},
      {:horde, "~> 0.8.7"},
      {:observer_cli, "~> 1.7"},
      {:memento, "~> 0.3.2"},
      # {:mnesia_eleveldb, git: "https://github.com/klarna/mnesia_eleveldb", tag: "1.1.1"},
      {:mnesia_rocksdb, git: "https://github.com/aeternity/mnesia_rocksdb.git", tag: "master"},
      {:libcluster, "~> 3.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
