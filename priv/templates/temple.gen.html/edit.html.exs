h1 do: "Edit <%= schema.human_singular %>"

render("form.html", Map.put(assigns, :action, Routes.<%= schema.route_helper %>_path(@conn, :update, @<%= schema.singular %>)))

span do
  link "Back", to: Routes.<%= schema.route_helper %>_path(@conn, :index)
end
