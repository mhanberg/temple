h1 do: "Listing <%= schema.human_plural %>"

table do
  thead do
    tr do <%= for {k, _} <- schema.attrs do %>
      th do: "<%= Phoenix.Naming.humanize(Atom.to_string(k)) %>"<% end %>
      th()
    end
    tbody do
      for <%= schema.singular %> <- @<%= schema.plural %> do
        tr do <%= for {k, _} <- schema.attrs do %>
          td do: <%= schema.singular %>.<%= k %> <% end %>
          td do
            link "Show", to: Routes.<%= schema.route_helper %>_path(@conn, :show, <%= schema.singular %>)
            link "Edit", to: Routes.<%= schema.route_helper %>_path(@conn, :edit, <%= schema.singular %>)
            link "Delete", to: Routes.<%= schema.route_helper %>_path(@conn, :delete, <%= schema.singular %>),
              method: :delete, data: [confirm: "Are you sure?"]
          end
        end
      end
    end
  end
end

span do
  link "New <%= schema.human_singular %>", to: Routes.<%= schema.route_helper %>_path(@conn, :new)
end
