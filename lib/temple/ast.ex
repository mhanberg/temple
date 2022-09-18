defmodule Temple.Ast do
  @moduledoc false

  alias Temple.Parser.Empty
  alias Temple.Parser.Text
  alias Temple.Parser.Components
  alias Temple.Parser.Slot
  alias Temple.Parser.NonvoidElementsAliases
  alias Temple.Parser.VoidElementsAliases
  alias Temple.Parser.AnonymousFunctions
  alias Temple.Parser.RightArrow
  alias Temple.Parser.DoExpressions
  alias Temple.Parser.Match
  alias Temple.Parser.Default

  @type ast ::
          %Empty{}
          | %Text{}
          | %Components{}
          | %Slot{}
          | %NonvoidElementsAliases{}
          | %VoidElementsAliases{}
          | %AnonymousFunctions{}
          | %RightArrow{}
          | %DoExpressions{}
          | %Match{}
          | %Default{}

  @doc """
  Should return true if the parser should apply for the given AST.
  """
  @callback applicable?(ast :: Macro.t()) :: boolean()

  @doc """
  Processes the given AST, adding the markup to the given buffer.

  Should return Temple.AST.
  """
  @callback run(ast :: Macro.t()) :: ast()

  def new(module, opts \\ []) do
    struct(module, opts)
  end
end
