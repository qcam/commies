defmodule Mix.Tasks.Docker.Build do
  use Mix.Task

  @image_name Atom.to_string(Mix.Project.config()[:app])

  def run(_args) do
    if System.find_executable("docker") do
      version = Mix.Project.config()[:version]
      image_tag = "#{@image_name}:#{version}"
      execute_docker(["build", "--tag", image_tag, "."])
      release_dir = "#{System.cwd!()}/_release"
      execute_docker(["run", "--rm", "--volume", "#{release_dir}:/release/", image_tag])
    else
      Mix.raise("The \"docker\" executable is not found")
    end
  end

  defp execute_docker(args) do
    {_stream, status} =
      System.cmd("docker", args, into: IO.stream(:stdio, :line), stderr_to_stdout: true)

    if status != 0 do
      Mix.raise("The \"docker\" command returned non-zero exit status")
    end
  end
end
