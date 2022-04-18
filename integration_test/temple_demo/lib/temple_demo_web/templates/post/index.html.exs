h1 do: "Listing Posts"

span id: "empty-tag"

span id: "non-empty-tag" do
  "got something in here"
end

table class: "border border-black" do
  c &headers/1 do
    th do: "Title"
    th do: "Body"
    th do: "Published at"
    th do: "Author"
    th do: "BOB"
  end

  tbody do
    for post <- @posts do
      tr do
        td do: post.title
        td do: post.body
        td do: post.published_at
        td do: post.author

        td do
          link "Show", to: Routes.post_path(@conn, :show, post)
          link "Edit", to: Routes.post_path(@conn, :edit, post)

          link "Delete",
            to: Routes.post_path(@conn, :delete, post),
            method: :delete,
            data: [confirm: "Are you sure?"]
        end
      end
    end
  end
end

span do
  link "New Post", to: Routes.post_path(@conn, :new)
end
