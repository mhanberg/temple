h1 do:  "Show <%= schema.human_singular %>"

ul do <%= for {k, _} <- schema.attrs do %>
  li do
    strong "<%= Phoenix.Naming.humanize(Atom.to_string(k)) %>"
    @<%= schema.singular %>.<%= k %>
  end <% end %>

  span do
    link "Edit", to: Routes.<%= schema.route_helper %>_path(@conn, :edit, @<%= schema.singular %>)
  end

  span do
    link "Back", to: Routes.<%= schema.route_helper %>_path(@conn, :index)
  end
end
