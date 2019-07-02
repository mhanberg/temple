h1 "Show <%= schema.human_singular %>"

ul do <%= for {k, _} <- schema.attrs do %>
  li do
    strong "<%= Phoenix.Naming.humanize(Atom.to_string(k)) %>"
    text @<%= schema.singular %>.<%= k %>
  end <% end %>

  span do
    phx_link "Edit", to: Routes.<%= schema.route_helper %>_path(@conn, :edit, @<%= schema.singular %>)
  end

  span do
    phx_link "Back", to: Routes.<%= schema.route_helper %>_path(@conn, :index)
  end
end
