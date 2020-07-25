defmodule Temple.Parser.Components do
  @behaviour Temple.Parser
  @component_prefix Application.fetch_env!(:temple, :component_prefix)

  alias Temple.Parser

  def applicable?({name, meta, _}) when is_atom(name) do
    !meta[:temple_component_applied] &&
      match?({:module, _}, name |> component_module() |> Code.ensure_compiled())
  end

  def applicable?(_), do: false

  defp component_module(name) do
    Module.concat([@component_prefix, Macro.camelize(to_string(name))])
  end

  def run({name, _meta, args}, _buffer) do
    {assigns, children} =
      case args do
        [assigns, [do: block]] ->
          {assigns, block}

        [[do: block]] ->
          {nil, block}

        [assigns] ->
          {assigns, nil}

        _ ->
          {nil, nil}
      end

    component_module = Module.concat([@component_prefix, Macro.camelize(to_string(name))])

    ast = apply(component_module, :render, [])

    {name, meta, args} =
      ast
      |> Macro.prewalk(fn
        {:@, _, [{:children, _, _}]} ->
          children

        {:@, _, [{:temple, _, _}]} ->
          assigns

        {:@, _, [{name, _, _}]} = node ->
          if !is_nil(assigns) && name in Keyword.keys(assigns) do
            Keyword.get(assigns, name, nil)
          else
            node
          end

        node ->
          node
      end)

    ast =
      if Enum.any?(
           [
             Parser.nonvoid_elements(),
             Parser.nonvoid_elements_aliases(),
             Parser.void_elements(),
             Parser.void_elements_aliases()
           ],
           fn elements -> name in elements end
         ) do
        {name, Keyword.put(meta, :temple_component_applied, true), args}
      else
        {name, meta, args}
      end

    {:component_applied, ast}
  end
end
