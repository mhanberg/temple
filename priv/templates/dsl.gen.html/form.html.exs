form_for @changeset, @action do 
  if @changeset.action do
    div class: "alert alert-danger" do
      p "Oops, something went wrong! Please check the errors below." 
    end
  end <%= for {label, input, error} <- inputs, input do %>
  <%= label %>
  <%= input %>
  <%= error %> <% end %>
  div do
    submit "Save"
  end
end
