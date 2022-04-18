"<!DOCTYPE html>"

html lang: "en" do
  head do
    meta charset: "utf-8"
    meta http_equiv: "X-UA-Compatible", content: "IE=edge"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"

    title do: "TempleDemo · Phoenix Framework"

    _link(rel: "stylesheet", href: Routes.static_path(@conn, "/css/app.css"))
  end

  body do
    main role: "main", class: "container" do
      for {type, message} <- get_flash(@conn) do
        p(class: "alert alert-#{type}", role: "alert", do: message)
      end

      @inner_content
    end

    script(type: "text/javascript", src: Routes.static_path(@conn, "/js/phoenix_html.js"))
    script(type: "text/javascript", src: Routes.static_path(@conn, "/js/app.js"))
  end
end
