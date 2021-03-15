defmodule Temple.Ast do
  defstruct content: nil, attrs: [], children: [], meta: %{}

  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end
end
