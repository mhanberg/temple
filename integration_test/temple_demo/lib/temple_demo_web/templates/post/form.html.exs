c Form, changeset: @changeset, action: @action do
  slot :f, %{f: f} do
    if @changeset.action do
      c Flash, type: :info do
        p do: "Oops, something went wrong! Please check the errors below."
      end
    end

    label f, :title
    text_input f, :title
    error_tag(f, :title)

    label f, :body
    textarea f, :body
    error_tag(f, :body)

    label f, :published_at
    datetime_select f, :published_at
    error_tag(f, :published_at)

    label f, :author
    text_input f, :author
    error_tag(f, :author)

    input type: "text", disabled: true, id: "disabled-input"

    div do
      submit "Save"
    end
  end
end
