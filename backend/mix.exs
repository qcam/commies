defmodule Commies.MixProject do
  use Mix.Project

  @version "0.2.2"

  def project() do
    [
      app: :commies,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application() do
    [
      mod: {Commies, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps() do
    [
      {:plug, "~> 1.5.1"},
      {:cowboy, "~> 1.1"},
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:hackney, "== 1.6.5"},
      {:distillery, "~> 1.5", runtime: false},
      {:dicon, "~> 0.5.0", runtime: false},
      {:mox, "~> 0.3.2", only: [:test]}
    ]
  end
end
