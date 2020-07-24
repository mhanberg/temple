defmodule Temple.Parser.Components do
  @behaviour Temple.Parser
  @components_path Application.get_env(:temple, :components_path, "./lib/components")

  alias Temple.Parser

  def applicable?({name, meta, _}) when is_atom(name) do
    !meta[:temple_component_applied] && File.exists?(Path.join([@components_path, "#{name}.exs"]))
  end

  def applicable?(_), do: false

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

    ast =
      File.read!(Path.join([@components_path, "#{name}.exs"]))
      |> Code.string_to_quoted!()

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
