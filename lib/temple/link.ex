defmodule Temple.Link do
  alias Phoenix.HTML
  alias Temple.Utils

  @moduledoc """
  This modules wraps all of the functions from the `Phoenix.HTML.Link` module to make them compatible with with Temple.
  """

  @doc """
  Please see `Phoenix.HTML.Link.link/2` for details.
  """
  defmacro phx_link(opts, do: block) do
    quote location: :keep do
      {:safe, link} =
        temple(do: unquote(block))
        |> HTML.Link.link(unquote(opts))

      Utils.put_buffer(var!(buff, Temple.Tags), link)
    end
  end

  defmacro phx_link(content, opts) do
    quote location: :keep do
      {:safe, link} = HTML.Link.link(unquote_splicing([content, opts]))

      Utils.put_buffer(var!(buff, Temple.Tags), link)
    end
  end

  @doc """
  Please see `Phoenix.HTML.Link.button/2` for details.
  """
  defmacro phx_button(opts, do: block) do
    quote location: :keep do
      {:safe, link} = HTML.Link.button(temple(do: unquote(block)), unquote(opts))

      Utils.put_buffer(var!(buff, Temple.Tags), link)
    end
  end

  defmacro phx_button(content, opts) do
    quote location: :keep do
      {:safe, link} = HTML.Link.button(unquote_splicing([content, opts]))

      Utils.put_buffer(var!(buff, Temple.Tags), link)
    end
  end
end
