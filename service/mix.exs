defmodule Service.MixProject do
  use Mix.Project

  def project do
    [
      app: :service,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Service.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:muontrap, "~> 0.4"},
      {:uuid, "~> 1.1"},
      {:socket, "~> 0.3"},
      {:shorter_maps, "~> 2.0"},
      {:connection, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
