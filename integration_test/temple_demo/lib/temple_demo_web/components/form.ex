defmodule TempleDemoWeb.Component.Form do
  import Temple

  def render(assigns) do
    temple do
      f = Phoenix.HTML.Form.form_for(@changeset, @action)

      f

      slot :f, f: f

      "</form>"
    end
  end
end
