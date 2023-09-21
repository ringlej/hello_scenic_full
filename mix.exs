defmodule HelloScenicFull.MixProject do
  use Mix.Project

  @app :hello_scenic_full
  @all_targets [
    :rpi3
  ]

def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.11",
      archives: [nerves_bootstrap: "~> 1.11"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HelloScenicFull, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.7.6", override: true},
      {:scenic, "~> 0.11.1"},
      scenic_driver_local(),
      {:scenic_clock, "~> 0.11.0"},

      # Dependencies for all targets
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.10.0"},
      {:toolshed, "~> 0.3.0"},

      # Allow Nerves.Runtime on host to support development, testing and CI.
      # See config/host.exs for usage.
      {:nerves_runtime, "~> 0.13.0"},

      # Dependencies for all targets except :host
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},

      nerves_system_rpi3(),
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

  defp scenic_driver_local do
    case Mix.target() do
      :rpi3 ->
        System.put_env("SCENIC_LOCAL_TARGET", "cairo")
      _ ->
        System.put_env("SCENIC_LOCAL_TARGET", "glfw")
    end

    path = System.get_env("SCENIC_DRIVER_LOCAL_PATH", "")

    case File.exists?(path) do
      true ->
        {:scenic_driver_local, path: path, targets: [:host, :rpi3]}

      _ ->
        {:scenic_driver_local,
         github: "gridpoint-com/scenic_driver_local",
         ref: "5110321c0e037cbae7e3f3bc743d51b8b2780255",
         targets: [:host, :rpi3]}
    end
  end

  defp nerves_system_rpi3 do
    path = System.get_env("RPI3_SYSTEM_PATH", "")

    case File.exists?(path) do
      true ->
        {:nerves_system_rpi3, path: path, runtime: false, targets: :rpi3}

      _ ->
        {:nerves_system_rpi3, "~> 1.21", runtime: false, targets: :rpi3}
    end
  end
end
