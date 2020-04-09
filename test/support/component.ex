defmodule Temple.Support.Component do
  import Temple

  defcomponent :flex do
    div(class: "flex")
  end

  defcomponent :takes_children do
    div do
      div(id: "static-child-1")
      @children
      div(id: "static-child-2")
    end
  end

  defcomponent :lists_assigns do
    partial inspect(@assigns) |> Phoenix.HTML.raw()
  end

  defcomponent :arbitrary_code do
    num = 1..10 |> Enum.reduce(0, fn x, sum -> x + sum end)

    div do
      text(num)
    end
  end

  defcomponent :uses_conditionals do
    if @condition do
      div()
    else
      span()
    end
  end

  defcomponent :arbitrary_data do
    for item <- @lists do
      div do
        text(inspect(item))
      end
    end
  end

  defcomponent :safe do
    div()
  end

  defcomponent :safe_with_prop do
    div id: "safe-with-prop" do
      text(@prop)

      div do
        span do
          for x <- @lists do
            div(do: text(x))
          end
        end
      end
    end
  end

  defcomponent :variable_as_prop do
    div id: @bob
  end

  defcomponent :variable_as_prop_with_block do
    div id: @bob do
      @children
    end
  end
end
