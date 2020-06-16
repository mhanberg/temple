defmodule TempleDemo.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :published_at, :naive_datetime
      add :author, :string

      timestamps()
    end

  end
end
