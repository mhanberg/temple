defmodule TempleDemoWeb.PageController do
  use TempleDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
