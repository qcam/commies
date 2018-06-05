defmodule Commies.MixProject do
  use Mix.Project

  def project() do
    [
      app: :commies,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      mod: {Commies, []},
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:plug, "~> 1.5.1"}
    ]
  end
end
