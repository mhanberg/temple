defmodule Dsl do
  @moduledoc """
  Documentation for Dsl.
  """

  def __using__(_) do
    quote do
      import Kernel, except: [div: 2]
      import Dsl.Html
    end
  end
end
