defmodule Mix.Tasks.HtmlToTempleTest do
  use ExUnit.Case, async: true

  test "converts html to temple syntax" do
    html = """
    <html lang="en">
      <head>
        <meta>
        <script></script>
        <link>
      </head>
      <body>
        <header class="header" data-action="do a thing"> 
          <nav role="navigation">
            <ul>
              <li><a href="/home">Home</a></li>
              <li><a href="/about">About</a></li>
              <li><a href="/profile">Profile</a></li>
            </ul>
          </nav>
        </header>

        <main role="main">
          <svg>
            <path d="alksdjfalksdjfslkadfj"/>
            <linearGradient>
              <stop></stop>
            </linearGradient
          </svg>
        </main>

        <footer></footer>
      </body>
    </html>
    """

    {:ok, result} = Temple.HtmlToTemple.parse(html)

    assert result === """
           html lang: "en" do
             head do
               meta()

               script()

               link()
             end

             body do
               header class: "header", "data-action": "do a thing" do
                 nav role: "navigation" do
                   ul do
                     li do
                       a href: "/home" do
                         text "Home"
                       end
                     end

                     li do
                       a href: "/about" do
                         text "About"
                       end
                     end

                     li do
                       a href: "/profile" do
                         text "Profile"
                       end
                     end
                   end
                 end
               end

               main role: "main" do
                 svg do
                   path d: "alksdjfalksdjfslkadfj"

                   linearGradient do
                     stop()
                   end
                 end
               end

               footer()
             end
           end
           """
  end

  test "parses HTML fragments" do
    html = """
    <section class="phx-hero">
      <h1><%= gettext "Welcome to %{name}!", name: "Phoenix" %></h1>
      <p>A productive web framework that<br/>
        does not compromise speed or maintainability.</p>
    </section>
    <section class="row">
      <article class="column">
        <h2>Resources</h2>
        <ul>
          <li>
            <a href="https://hexdocs.pm/phoenix/overview.html">Guides &amp; Docs</a>
          </li>
        </ul>
      </article>
    </section>
    """

    {:ok, result} = Temple.HtmlToTemple.parse(html)

    assert result === """
           section class: "phx-hero" do
             h1 do
               text "<%= gettext \"Welcome to %{name}!\", name: \"Phoenix\" %>"
             end

             p do
               text "A productive web framework that"

               br()

               text "
               does not compromise speed or maintainability."
             end
           end

           section class: "row" do
             article class: "column" do
               h2 do
                 text "Resources"
               end

               ul do
                 li do
                   a href: "https://hexdocs.pm/phoenix/overview.html" do
                     text "Guides & Docs"
                   end
                 end
               end
             end
           end
           """
  end
end
