defmodule Temple.Parser.Slottable do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :content, any()
    field :assigns, map(), default: Macro.escape(%{})
    field :name, atom()
  end
end
