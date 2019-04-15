defmodule Dsl do
  @moduledoc """
  Documentation for Dsl.
  """

  defmacro __using__(_) do
    quote do
      import Dsl.Html
    end
  end
end
