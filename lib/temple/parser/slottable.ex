defmodule Temple.Parser.Slottable do
  defstruct content: nil, assigns: Macro.escape(%{}), name: nil
end
