defmodule Temple.Ast do
  @moduledoc false

  def new(module, opts \\ []) do
    struct(module, opts)
  end
end
