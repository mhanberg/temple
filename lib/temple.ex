defmodule Temple do
  defmacro __using__(_) do
    quote location: :keep do
      import Temple
    end
  end

  @doc """
  Creates a markup context.

  All tags must be called inside of a `Temple.temple/1` block.

  Returns a safe result of the form `{:safe, result}`

  ## Example

  ```
  team = ["Alice", "Bob", "Carol"]

  temple do
    for name <- team do
      div class: "text-bold" do
        text name
      end
    end
  end

  # {:safe, "<div class=\"text-bold\">Alice</div><div class=\"text-bold\">Bob</div><div class=\"text-bold\">Carol</div>"}
  ```
  """
  defmacro temple([do: block] = _block) do
    quote location: :keep do
      import Kernel, except: [div: 2, use: 1, use: 2]
      import Temple.Html
      import Temple.Svg
      import Temple.Form
      import Temple.Link

      with {:ok, var!(buff, Temple.Html)} <- Temple.Utils.start_buffer([]) do
        unquote(block)

        markup = Temple.Utils.get_buffer(var!(buff, Temple.Html))

        :ok = Temple.Utils.stop_buffer(var!(buff, Temple.Html))

        Temple.Utils.join_and_escape(markup)
      end
    end
  end

  @doc """
  Emits a text node into the markup.

  ```
  temple do
    div do
      text "Hello, world!"
    end
  end

  # {:safe, "<div>Hello, world!</div>"}
  ```
  """
  defmacro text(text) do
    quote location: :keep do
      Temple.Utils.put_buffer(
        var!(buff, Temple.Html),
        unquote(text) |> Temple.Utils.escape_content()
      )
    end
  end

  @doc """
  Emits a Phoenix partial into the markup.

  ```
  temple do
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
    quote location: :keep do
      Temple.Utils.put_buffer(
        var!(buff, Temple.Html),
        unquote(partial) |> Temple.Utils.from_safe()
      )
    end
  end

  @doc """
  Defines a custom component.

  Components are the primary way to extract partials and markup helpers.

  ## Assigns

  Components accept a keyword list or a map of assigns and can be referenced in the body of the component by a module attribute of the same name.

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

  temple do
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
  defmacro defcomponent(name, params \\ [], [do: _] = block) do
    param = fn name ->
      Macro.var(name, __MODULE__)
    end

    quote location: :keep do
      defmacro unquote(name)(unquote_splicing(params)) do
        params =
          unquote(
            Enum.map(params, fn {param_name, _, _} = param ->
              {param_name, param}
            end)
          )

        outer =
          unquote(Macro.escape(block))
          |> Temple.Utils.__insert_params__(params)

        Temple.Utils.__quote__(outer)
      end

      defmacro unquote(name)(props_or_block)

      defmacro unquote(name)(unquote_splicing(params ++ [[{:do, param.(:inner)}]])) do
        params =
          unquote(
            Enum.map(params, fn {param_name, _, _} = param ->
              {param_name, param}
            end)
          )

        outer =
          unquote(Macro.escape(block))
          |> Temple.Utils.__insert_props__([], inner)
          |> Temple.Utils.__insert_params__(params)

        Temple.Utils.__quote__(outer)
      end

      defmacro unquote(name)(unquote_splicing(params ++ [param.(:props)])) do
        params =
          unquote(
            Enum.map(params, fn {param_name, _, _} = param ->
              {param_name, param}
            end)
          )

        outer =
          unquote(Macro.escape(block))
          |> Temple.Utils.__insert_props__(props, nil)
          |> Temple.Utils.__insert_params__(params)

        Temple.Utils.__quote__(outer)
      end

      defmacro unquote(name)(unquote_splicing(params ++ [param.(:props), param.(:inner)])) do
        params =
          unquote(
            Enum.map(params, fn {param_name, _, _} = param ->
              {param_name, param}
            end)
          )

        outer =
          unquote(Macro.escape(block))
          |> Temple.Utils.__insert_props__(props, inner)
          |> Temple.Utils.__insert_params__(params)

        Temple.Utils.__quote__(outer)
      end
    end
  end
end
