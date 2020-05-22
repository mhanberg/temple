form_for @changeset, @action, fn f ->
  if @changeset.action do
    div class: "alert alert-danger" do
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

  div do
    submit "Save"
  end
end
