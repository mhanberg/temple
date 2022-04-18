defmodule TemplePlugDemo.Router do
  use Plug.Router

  import Temple

  plug Plug.Static, from: {:temple_plug_demo, "priv/static"}, at: "/static"

  plug :match
  plug :dispatch

  get "/" do
    assigns = %{title: "Motch App"}

    response =
      temple do
        "<!DOCTYPE html>"

        html do
          head do
            title do: @title

            link rel: "stylesheet", href: "/static/assets/app.css"
          end

          body class: "font-sans container mx-auto" do
            span do
              "loose"
            end

            span do: "tight"

            div do
              "world"
            end
          end
        end
      end

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, response)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
