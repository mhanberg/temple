defmodule Temple.Component do
  @moduledoc """
  Behaviour for defining temple components.
  """

  @doc """
  The render callback must return AST to be inserted into the markup. 

  Since you need to return AST, it is typical to wrap the contents of the function in a `quote` block like:

  ```
  @impl Temple.Component
  def render() do
    quote do
      div do
        @children
      end
    end
  end
  ```
  """
  @callback render() :: Macro.t()
end
