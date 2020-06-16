h1 do: "Show Post"

ul do 
  li do: [strong(do: "Title"), @post.title]
  li do
    strong do: "Body"
    Phoenix.HTML.Format.text_to_html @post.body, attributes: [class: "whitespace-pre"]
  end 
  li do
    strong do: "Published at"
    @post.published_at
  end 
  li do
    strong do: "Author"
    @post.author
  end 

  span do
    link "Edit", to: Routes.post_path(@conn, :edit, @post)
  end

  span do
    link "Back", to: Routes.post_path(@conn, :index)
  end
end
