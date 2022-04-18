section class: "phx-hero" do
  h1 do
    gettext("Welcome to %{name}!", name: "Phoenix")
  end

  c &Outer.render/1, outer_id: "hello" do
    "inner content of outer"
  end

  case @text do
    "staging" ->
      p do
        "Peace-of-mind from prototype to staging"
      end

    _ ->
      p do
        "Peace-of-mind from prototype to production"
      end
  end
end

section class: "row" do
  article class: "column" do
    h2 do: "Resources"

    ul do
      li do
        a href: "https://hexdocs.pm/phoenix/overview.html" do
          "Guides &amp; Docs"
        end
      end

      li do
        a href: "https://github.com/phoenixframework/phoenix" do
          "Source"
        end
      end

      li do
        a href: "https://github.com/phoenixframework/phoenix/blob/v1.5/CHANGELOG.md" do
          "v1.5 Changelog"
        end
      end
    end
  end

  article class: "column" do
    h2 do: "Help"

    ul do
      li do
        a href: "https://elixirforum.com/c/phoenix-forum" do
          "Forum"
        end
      end

      li do
        a href: "https://webchat.freenode.net/?channels=elixir-lang" do
          "#elixir-lang on Freenode IRC"
        end
      end

      li do
        a href: "https://twitter.com/elixirphoenix" do
          "Twitter @elixirphoenix"
        end
      end

      li do
        a href: "https://elixir-slackin.herokuapp.com/" do
          "Elixir on Slack"
        end
      end
    end
  end
end
