defmodule Temple.Ast do
  @moduledoc false

  @type t ::
          Temple.Parser.Empty.t()
          | Temple.Parser.Text.t()
          | Temple.Parser.Components.t()
          | Temple.Parser.Slot.t()
          | Temple.Parser.NonvoidElementsAliases.t()
          | Temple.Parser.VoidElementsAliases.t()
          | Temple.Parser.AnonymousFunctions.t()
          | Temple.Parser.RightArrow.t()
          | Temple.Parser.DoExpressions.t()
          | Temple.Parser.Match.t()
          | Temple.Parser.Default.t()

  def new(module, opts \\ []) do
    struct(module, opts)
  end
end
