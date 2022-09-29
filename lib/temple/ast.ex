defmodule Temple.Ast do
  @moduledoc false

  @type t ::
          Temple.Ast.Empty.t()
          | Temple.Ast.Text.t()
          | Temple.Ast.Components.t()
          | Temple.Ast.Slot.t()
          | Temple.Ast.NonvoidElementsAliases.t()
          | Temple.Ast.VoidElementsAliases.t()
          | Temple.Ast.AnonymousFunctions.t()
          | Temple.Ast.RightArrow.t()
          | Temple.Ast.DoExpressions.t()
          | Temple.Ast.Match.t()
          | Temple.Ast.Default.t()

  def new(module, opts \\ []) do
    struct(module, opts)
  end
end
