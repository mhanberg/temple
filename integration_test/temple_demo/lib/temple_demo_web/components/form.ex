defmodule TempleDemoWeb.Component.Form do
  import Temple.Component

  render do
    f = Phoenix.HTML.Form.form_for(@changeset, @action)

    f

    slot :f, f: f

    "</form>"
  end
end
