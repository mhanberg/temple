h1 do: "Edit Post"

render("form.html", Map.put(assigns, :action, Routes.post_path(@conn, :update, @post)))

span do
  link "Back", to: Routes.post_path(@conn, :index)
end
