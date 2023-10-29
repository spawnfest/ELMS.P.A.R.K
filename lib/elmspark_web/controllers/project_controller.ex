defmodule ElmsparkWeb.ProjectController do
  use ElmsparkWeb, :controller

  def show(conn, %{"id" => blueprint_id}) do
    if File.exists?(release_directory(blueprint_id, ["index.html"])) do
      content = File.read!(release_directory(blueprint_id, ["index.html"]))

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, content)
    else
      send_resp(conn, 404, "Project Not Found.")
    end
  end

  defp release_directory(blueprint_id, p) do
    ["priv", "static", "assets", blueprint_id]
    |> Enum.concat(p)
    |> Path.join()
  end
end
