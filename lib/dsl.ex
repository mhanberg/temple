defmodule Dsl do
  @moduledoc """
  Documentation for Dsl.
  """

  defmacro __using__(_) do
    quote do
      import Dsl.Tags
      import Dsl.Form
    end
  end
end
