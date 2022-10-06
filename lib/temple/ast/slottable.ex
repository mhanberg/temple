defmodule Temple.Ast.Slottable do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :content, [Temple.Ast.t()]
    field :parameter, Macro.t()
    field :name, atom()
    field :attributes, Macro.t(), default: []
  end
end
