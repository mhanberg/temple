defmodule Temple.Ast.Slottable do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :content, any()
    field :assigns, map()
    field :name, atom()
  end
end
