defmodule Elmspark.Elmspark.ElmMakeServer do
  use GenServer
  require Logger

  # CLIENT

  def new_project(project_id, blueprint_id) do
    # TODO: Don't allow name collisions
    GenServer.call(__MODULE__, {:new_project, project_id, blueprint_id})
  end

  def get_project(project_id) do
    GenServer.call(__MODULE__, {:get_project, project_id})
  end

  def make_elm(blueprint_id, contents) do
    GenServer.call(__MODULE__, {:make_elm, blueprint_id, contents})
  end

  def gen_js(blueprint_id, contents) do
    GenServer.call(__MODULE__, {:gen_js, blueprint_id, contents})
  end

  # SERVER

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts, {:continue, :initialize_elm_projects}}
  end

  def handle_continue(:initialize_elm_projects, opts) do
    Logger.info("Starting Elm Make Server")

    if not File.dir?("projects") do
      :ok = File.mkdir("projects")
    end

    {:noreply, opts}
  end

  def handle_call({:new_project, project_id, blueprint_id}, _from, opts) do
    Logger.info("Creating a new Project for Blueprint #{blueprint_id}")
    working_dir = working_directory(project_id)

    case File.mkdir(working_dir) do
      :ok ->
        System.cmd("sh", ["-c", "echo 'Y' | elm init"], cd: working_dir)
        {:reply, {:ok, working_dir}, opts}

      {:error, e} ->
        Logger.error("Error creating new project: #{e}")
        {:reply, {:error, e}, opts}
    end
  end

  def handle_call({:get_project, project_id}, _from, opts) do
    Logger.info("Get Project for Blueprint #{project_id}")
    working_dir = working_directory(project_id)

    if File.dir?(working_dir) do
    else
      {:reply, {:error, :project_not_found}, opts}
    end

    case File.mkdir(working_dir) do
      :ok ->
        System.cmd("sh", ["-c", "echo 'Y' | elm init"], cd: working_dir)
        {:reply, {:ok, working_dir}, opts}

      {:error, e} ->
        Logger.error("Error creating new project: #{e}")
        {:reply, {:error, e}, opts}
    end
  end

  def handle_call({:gen_js, blueprint_id, contents}, _from, opts) do
    Logger.info("Generating JS")
    working_dir = working_directory(blueprint_id)
    path = working_directory(blueprint_id, ["src", "Main.elm"])
    File.write(path, contents)
    # args = ["make", "--output=main.js", "src/Main.elm"]
    args = ["make", "src/Main.elm"]

    with {:ok, blah} <- Rambo.run("elm", args, cd: working_dir) do
      Logger.info("Gen JS Run successful #{inspect(blah)}")
      output_path = working_directory(blueprint_id, ["index.html"])
      release_dir = release_directory(blueprint_id)

      if not File.dir?(release_dir) do
        :ok = File.mkdir(release_dir)
      end

      release_path = release_directory(blueprint_id, ["index.html"])

      case File.cp(output_path, release_path) do
        :ok ->
          {:reply, {:ok, blah}, opts}

        {:error, err} ->
          {:reply, {:error, err}, opts}
      end
    else
      {:error, %Rambo{err: error}} ->
        Logger.info("Elm Make Failed run failed")
        {:reply, {:error, error}, opts}
    end
  end

  def handle_call({:make_elm, blueprint_id, contents}, _from, opts) do
    working_dir = working_directory(blueprint_id)
    path = working_directory(blueprint_id, ["src", "Main.elm"])
    File.write(path, contents)
    System.cmd("sh", ["-c", " elm-format src/Main.elm --yes"])

    # Setup the redirection of standard error
    # Run the elm make command using ports
    # args = ["make", "--report=json", "src/Main.elm"]
    args = ["make", "--report=json", "src/Main.elm"]

    with {:ok, blah} <- Rambo.run("elm", args, cd: working_dir) do
      Logger.info("Elm Make Run successful #{inspect(blah)}")
      {:reply, {:ok, blah}, opts}
    else
      {:error, %Rambo{err: error}} ->
        Logger.info("Elm Make Failed run failed")
        {:reply, {:error, error}, opts}
    end
  end

  def handle_info(msg, state) do
    Logger.info("Got message: #{inspect(msg)}")
    {:noreply, state}
  end

  defp working_directory(blueprint_id, p \\ []) do
    ["projects", blueprint_id]
    |> Enum.concat(p)
    |> Path.join()
  end

  defp release_directory(blueprint_id, p \\ []) do
    ["priv", "static", "assets", blueprint_id]
    |> Enum.concat(p)
    |> Path.join()
  end
end
