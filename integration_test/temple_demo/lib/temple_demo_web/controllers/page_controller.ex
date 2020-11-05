defmodule TempleDemoWeb.PageController do
  use TempleDemoWeb, :controller

  def index(conn, params) do
    render(conn, "index.html", text: params["text"])
  end
end
