defmodule Temple.Parser.Slottable do
  @moduledoc false

  defstruct content: nil, assigns: Macro.escape(%{}), name: nil
end
