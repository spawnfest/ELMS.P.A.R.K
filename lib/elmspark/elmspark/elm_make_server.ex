defmodule Elmspark.Elmspark.ElmMakeServer do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts, {:continue, :initialize_elm_project}}
  end

  def handle_continue(:initialize_elm_project, opts) do
    Logger.info("Starting Elm Make Server")
    generate_elm_json()
    {:noreply, opts}
  end

  def generate_elm_json() do
    if File.exists?("elm.json") do
      Logger.info("elm.json file found")
    else
      System.cmd("sh", ["-c", "echo 'Y' | elm init"])
    end
  end

  def make_elm(contents) do
    GenServer.call(__MODULE__, {:make_elm, contents})
  end

  def gen_js(contents) do
    GenServer.call(__MODULE__, {:gen_js, contents})
  end

  def handle_call({:gen_js, contents}, _from, opts) do
    Logger.info("Generating JS")
    File.write("src/Main.elm", contents)
    args = ["make", "--output=main.js", "src/Main.elm"]

    with {:ok, blah} <- Rambo.run("elm", args) do
      Logger.info("Elm Make Run successful #{inspect(blah)}")
      {:reply, {:ok, blah}, opts}
    else
      {:error, %Rambo{err: error}} ->
        Logger.info("Elm Make Failed run failed")
        {:reply, {:error, error}, opts}
    end
  end

  def handle_call({:make_elm, contents}, _from, opts) do
    File.write("src/Main.elm", contents)
    System.cmd("sh", ["-c", " elm-format src/Main.elm --yes"])

    # Setup the redirection of standard error
    # Run the elm make command using ports
    # args = ["make", "--report=json", "src/Main.elm"]
    args = ["make", "--report=json", "src/Main.elm"]

    with {:ok, blah} <- Rambo.run("elm", args) do
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
end
