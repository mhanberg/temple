defmodule Temple.Ast do
  def new(module, opts \\ []) do
    struct(module, opts)
  end
end
