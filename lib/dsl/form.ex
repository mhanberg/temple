defmodule Dsl.Form do
  @moduledoc """
  This modules wraps all of the functions from the `Phoenix.HTML.Form` module to make them compatible with with Dsl.
  """

  alias Phoenix.HTML
  alias Dsl.Utils

  @doc """
  Generates an empty form tag.

  See `Dsl.Form.form_for/4` for more details
  """
  defmacro form_for(form_data, action) do
    quote do
      form_for(unquote_splicing([form_data, action]), [])
    end
  end

  @doc """
  Generates a form tag with a form builder and a block.

  The form builder will be available inside the block through the `form` variable.

  This is a wrapper around the `Phoenix.HTML.Form.form_for/4` function and accepts all of the same options.

  ## Example

  ```
  htm do
    form_for @conn, Routes.some_path(@conn, :create) do
      text_input form, :name
    end
  end

  # {:safe,
  #   "<form accept-charset=\"UTF-8\" action=\"/\" method=\"post\">
  #      <input name=\"_csrf_token\" type=\"hidden\" value=\"AS5qfX1gcns6eU56BlQgBlwCDgMlNgAAiJ0MR91Kh3v3bbCS5SKjuw==\">
  #      <input name=\"_utf8\" type=\"hidden\" value=\"✓\">
  #      <input id=\"name\" name=\"name\" type=\"text\">
  #    </form>"}
  ```
  """
  defmacro form_for(form_data, action, opts \\ [], block) do
    quote do
      var!(form) = HTML.Form.form_for(unquote_splicing([form_data, action, opts]))

      Utils.put_buffer(var!(buff, Dsl.Tags), var!(form) |> HTML.Safe.to_iodata())
      _ = unquote(block)
      Utils.put_buffer(var!(buff, Dsl.Tags), "</form>")
    end
  end

  @doc """
  Please see `Phoenix.HTML.Form.text_input/3` for details.
  """
  defmacro text_input(form, field, opts \\ []) do
    quote do
      {:safe, input} = HTML.Form.text_input(unquote_splicing([form, field, opts]))

      Utils.put_buffer(var!(buff, Dsl.Tags), input)
    end
  end
end
