defmodule Liquor.MixProject do
  use Mix.Project

  @version "1.0.1"

  def project do
    [
      app: :liquor,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ] ++ docs()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opengraph_parser, "~> 0.4.4"},
      {:req, "~> 0.4.14", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Liquor Tags. Inspired by dev.to embed tags (liquid tags), takes Open Graph data from URLs and generate output using pseudo EEx templates."
  end

  defp docs do
    [
      # Docs
      name: "Liquor Tags",
      source_url: "https://github.com/ElixirCL/liquor",
      homepage_url: "https://github.com/ElixirCL/liquor",
      docs: [
        # The main page in the docs
        main: "examples",
        # logo: "https://raw.githubusercontent.com/ElixirCL/elixircl.github.io/main/assets/logo.png",
        extras: ["README.md", "LICENSE.md", "CHANGELOG.md", "EXAMPLES.livemd", "AUTHORS.md"],
        authors: ["AUTHORS.md"],
        output: "docs"
      ]
    ]
  end

  defp package() do
    [
      name: "liquor",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["ElixirCL"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => "https://github.com/ElixirCL/liquor"}
      # Remove below comment to make the package private
      # organization: "elixircl_"
    ]
  end
end
