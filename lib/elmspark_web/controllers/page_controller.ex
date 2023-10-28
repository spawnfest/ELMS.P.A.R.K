defmodule ElmsparkWeb.PageController do
  use ElmsparkWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
  def show(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :show, layout: false)
  end
end
