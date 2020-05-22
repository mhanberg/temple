defmodule TempleDemo.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :author, :string
    field :body, :string
    field :published_at, :naive_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :published_at, :author])
    |> validate_required([:title, :body, :published_at, :author])
  end
end
