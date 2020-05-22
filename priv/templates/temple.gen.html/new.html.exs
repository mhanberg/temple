h1 do: "New <%= schema.human_singular %>"

render("form.html", Map.put(assigns, :action, Routes.<%= schema.route_helper %>_path(@conn, :create)))

span do
  link "Back", to: Routes.<%= schema.route_helper %>_path(@conn, :index)
end
