defmodule ElmsparkWeb.RenderLive do
  use ElmsparkWeb, :live_view

  def render(assigns) do
    ~H"""
    <div id="elmApp"></div>
    """
  end
end
