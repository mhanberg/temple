h1 do: "Show Post"

ul do 
  li do
    strong "Title"
    @post.title
  end 
  li do
    strong "Body"
    @post.body
  end 
  li do
    strong "Published at"
    @post.published_at
  end 
  li do
    strong "Author"
    @post.author
  end 

  span do
    link "Edit", to: Routes.post_path(@conn, :edit, @post)
  end

  span do
    link "Back", to: Routes.post_path(@conn, :index)
  end
end
