h1 "Edit <%= schema.human_singular %>"

partial render("form.html",
  Map.put(
    assigns,
    :action,
    Routes.<%= schema.route_helper %>_path(@conn, :update, @<%= schema.singular %>)
  )
)

span do
  phx_link "Back", to: Routes.<%= schema.route_helper %>_path(@conn, :index)
end
