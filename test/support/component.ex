defmodule Component do
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

  defcomponent takes_params(foo, bar_baz, num) do
    p do: text(foo)

    case bar_baz do
      :bar -> p do: text("bar")
      :baz -> p do: text("baz")
      _ -> nil
    end

    p do: text(num)
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

  defcomponent params_with_props_and_block(param) do
    div id: param do
      if param == @prop do
        @children
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

  defcomponent variable_as_param_with_block(bob) do
    div id: bob do
      @children
    end
  end
end
