html lang: "en" do
  head do
    meta charset: "utf-8"
    meta http_equiv: "X-UA-Compatible", content: "IE=edge"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"
    title "TempleDemo · Phoenix Framework"

    _link(rel: "stylesheet", href: Routes.static_path(@conn, "/css/app.css"))
  end

  body do
    header do
      section class: "container" do
        nav role: "navigation" do
          ul do
            li do
              a href: "https://hexdocs.pm/phoenix/overview.html" do
                "Get Started"
              end
            end
          end
        end

        a href: "http://phoenixframework.org/", class: "phx-logo" do
          img src: Routes.static_path(@conn, "/images/phoenix.png"),
              alt: "Phoenix Framework Logo"
        end
      end
    end

    main role: "main", class: "container" do
      if get_flash(@conn, :info) do
        p class: "alert alert-info", role: "alert" do
          get_flash(@conn, :info)
        end
      end

      if get_flash(@conn, :error) do
        p class: "alert alert-danger", role: "alert" do
          get_flash(@conn, :error)
        end
      end

      @inner_content
    end

    script type: "text/javascript", src: Routes.static_path(@conn, "/js/app.js")
  end
end
