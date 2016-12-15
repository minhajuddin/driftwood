defmodule Driftwood.Mixfile do
  use Mix.Project

  def project do
    [app: :driftwood,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    A log viewing plug which shows the latest logs from your app
    """
  end

  defp deps do
    [{:plug,    "~> 1.0"},
     {:earmark, "~> 1.0",  only: :dev},
     {:ex_doc,  "~> 0.14", only: :dev}]
  end

  defp package do
    [maintainers: ["Khaja Minhajuddin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/minhajuddin/driftwood"}]
  end
end
