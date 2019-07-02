h1 "Listing <%= schema.human_plural %>"

table do
  thead do
    tr do <%= for {k, _} <- schema.attrs do %>
      th "<%= Phoenix.Naming.humanize(Atom.to_string(k)) %>"<% end %>
      th()
    end
    tbody do
      for <%= schema.singular %> <- @<%= schema.plural %> do
        tr do <%= for {k, _} <- schema.attrs do %>
          td <%= schema.singular %>.<%= k %> <% end %>
          td do
            phx_link "Show", to: Routes.<%= schema.route_helper %>_path(@conn, :show, <%= schema.singular %>)
            phx_link "Edit", to: Routes.<%= schema.route_helper %>_path(@conn, :edit, <%= schema.singular %>)
            phx_link "Delete", to: Routes.<%= schema.route_helper %>_path(@conn, :delete, <%= schema.singular %>),
              method: :delete, data: [confirm: "Are you sure?"]
          end
        end
      end
    end
  end
end

span do
  phx_link "New <%= schema.human_singular %>", to: Routes.<%= schema.route_helper %>_path(@conn, :new)
end
