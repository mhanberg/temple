h1 do: "New Post"

render("form.html", Map.put(assigns, :action, Routes.post_path(@conn, :create)))

span do
  link "Back", to: Routes.post_path(@conn, :index)
end
