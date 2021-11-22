defmodule Temple.Components.SomeComponent do
  import Temple.Component

  alias Temple.Components.Link

  render do
    div class: "border-4 border-green-500" do
      section do
        c Link, href: "/", do: "Home"
        c Link, href: "/about", do: "About"
        c Link, href: "/posts", do: "Posts"
        c Link, href: "/jokes", do: "Dad Jokes"
        c Link, href: "/bookshelf", do: "Bookshelf"
      end

      slot :default
    end
  end
end
