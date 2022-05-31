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
      {:shorter_maps, "~> 2.2"},
      {:pipe_to, "~> 0.2.1"},
      {:sorted_set_nif, "~> 1.2.0"},
      {:ecto, "~> 3.8"},
      {:ecto_sql, "~> 3.8"},
      {:myxql, "~> 0.6.2"},
      {:nebulex, "~> 2.3"},
      {:shards, "~> 1.0"},
      {:decorator, "~> 1.4"},
      {:logger_file_backend, "~> 0.0.13"},
      {:protox, "~> 1.6"},
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.8.7"},
      {:observer_cli, "~> 1.7"},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:memento, "~> 0.3.2"}

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
