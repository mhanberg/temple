defmodule Temple do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Temple.Tags
      import Temple.Form
      import Temple.Link
    end
  end

  @doc """
  Creates a markup context.

  All tags must be called inside of a `Temple.htm/1` block.

  Returns a safe result of the form `{:safe, result}`

  ## Example

  ```
  team = ["Alice", "Bob", "Carol"]

  htm do
    for name <- team do
      div class: "text-bold" do
        text name
      end
    end
  end

  # {:safe, "<div class=\"text-bold\">Alice</div><div class=\"text-bold\">Bob</div><div class=\"text-bold\">Carol</div>"}
  ```
  """
  defmacro htm([do: block] = _block) do
    quote do
      import Kernel, except: [div: 2]
      import Phoenix.HTML.Link, except: [link: 1, link: 2]
      import Phoenix.HTML.Form, only: []

      Temple.Utils.lexical_scope(fn ->
        {:ok, var!(buff, Temple.Tags)} = Temple.Utils.start_buffer([])

        unquote(block)

        markup = Temple.Utils.get_buffer(var!(buff, Temple.Tags))

        :ok = Temple.Utils.stop_buffer(var!(buff, Temple.Tags))

        markup |> Enum.reverse() |> Enum.join("") |> Phoenix.HTML.raw()
      end)
    end
  end

  @doc """
  Emits a text node into the markup.

  ```
  htm do
    div do
      text "Hello, world!"
    end
  end

  # {:safe, "<div>Hello, world!</div>"}
  ```
  """
  defmacro text(text) do
    quote do
      Temple.Utils.put_buffer(
        var!(buff, Temple.Tags),
        unquote(text) |> to_string |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
      )
    end
  end

  @doc """
  Emits a Phoenix partial into the markup.

  ```
  htm do
    html lang: "en" do
      head do
        title "MyApp"

        link rel: "stylesheet", href: Routes.static_path(@conn, "/css/app.css")
      end

      body do
        main role: "main", class: "container" do
          p get_flash(@conn, :info), class: "alert alert-info", role: "alert"
          p get_flash(@conn, :error), class: "alert alert-danger", role: "alert"

          partial render(@view_module, @view_template, assigns)
        end

        script type: "text/javascript", src: Routes.static_path(@conn, "/js/app.js")
      end
    end
  end
  ```
  """
  defmacro partial(partial) do
    quote do
      Temple.Utils.put_buffer(
        var!(buff, Temple.Tags),
        unquote(partial) |> Temple.Utils.from_safe()
      )
    end
  end

  @doc """
  Defines a custom component.

  Components are the primary way to extract partials and markup helpers.

  ## Assigns

  Components accept a keyword list of assigns and can be referenced in the body of the component by a module attribute of the same name.

  This works exactly the same as EEx templates.

  ## Children

  If a block is passed to the component, it can be referenced by a special assign called `@children`.

  ## Example

  ```
  defcomponent :flex do
    div id: @id, class: "flex" do
      @children
    end
  end

  htm do
    flex id: "my-flex" do
      div "Item 1"
      div "Item 2"
      div "Item 3"
    end
  end

  # {:safe, "<div id=\"my-flex\" class=\"flex\">
  #            <div>Item 1</div>
  #            <div>Item 2</div>
  #            <div>Item 3</div>
  #          </div>"}
  ```
  """
  defmacro defcomponent(name, [do: _] = block) do
    quote do
      defmacro unquote(name)(props \\ []) do
        outer = unquote(Macro.escape(block))
        name = unquote(name)

        {inner, props} = Keyword.pop(props, :do, nil)

        quote do
          unquote(name)(unquote(props), unquote(inner))
        end
      end

      defmacro unquote(name)(props, inner) do
        import Kernel, except: [div: 2]

        outer =
          unquote(Macro.escape(block))
          |> Macro.prewalk(&Temple.Utils.insert_props(&1, [{:children, inner} | props]))

        name = unquote(name)

        quote do
          unquote(outer)
        end
      end
    end
  end
end
