defmodule Mix.Tasks.Compile.CheckElmDeps do
  use Mix.Task

  # Specify the task runtime dependencies
  @shortdoc "Checks for the presence of elm make, format"
  @recursive true

  def run(_) do
    # List of binaries to check
    binaries_to_check = ["elm", "elm-format"]

    binaries_to_check
    |> Enum.each(fn binary ->
      unless System.find_executable(binary) do
        IO.puts("Missing dependency: #{binary} is not installed or not in the PATH!")
        raise 1
      end
    end)

  end
end
