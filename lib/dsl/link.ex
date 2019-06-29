defmodule Dsl.Link do
  alias Phoenix.HTML
  alias Dsl.Utils

  @moduledoc """
  This modules wraps all of the functions from the `Phoenix.HTML.Link` module to make them compatible with with Dsl.
  """

  @doc """
  Please see `Phoenix.HTML.Link.link/2` for details.
  """
  defmacro phx_link(content_or_opts, opts_or_block) do
    quote do
      {:safe, link} = HTML.Link.link(unquote_splicing([content_or_opts, opts_or_block]))

      Utils.put_buffer(var!(buff, Dsl.Tags), link)
    end
  end

  @doc """
  Please see `Phoenix.HTML.Link.button/2` for details.
  """
  defmacro phx_button(content_or_opts, opts_or_block) do
    quote do
      {:safe, link} = HTML.Link.button(unquote_splicing([content_or_opts, opts_or_block]))

      Utils.put_buffer(var!(buff, Dsl.Tags), link)
    end
  end
end
