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
      {:exsync, "~> 0.2.4", only: :dev},
      {:limited_queue, "~> 0.1.0"},
      {:uuid, "~> 1.1"},
      {:shorter_maps, "~> 2.2"},
      {:pipe_to, "~> 0.2.1"},
      {:sorted_set_nif, "~> 1.2.0"},
      {:logger_file_backend, "~> 0.0.13"},
      {:worker_pool, "~> 6.0"},
      {:protox, "~> 1.6"},
      {:horde, "~> 0.8.7"},
      {:observer_cli, "~> 1.7"},
      {:libcluster, "~> 3.3"},
      {:ranch, "~> 2.1", override: true},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:poison, "~> 5.0"},
      {:lz4, "~> 0.2.4", hex: :lz4_erl},
      {:fastglobal, "~> 1.0"},
      {:manifold, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:earmark, "~> 1.4"},
      {:memoize, "~> 1.4"},
      {:pockets, "~> 1.2"}
    ]
  end

  defp aliases do
    []
  end
end
