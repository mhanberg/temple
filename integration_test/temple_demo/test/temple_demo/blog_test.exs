defmodule TempleDemo.BlogTest do
  use TempleDemo.DataCase

  alias TempleDemo.Blog

  describe "posts" do
    alias TempleDemo.Blog.Post

    @valid_attrs %{author: "some author", body: "some body", published_at: ~N[2010-04-17 14:00:00], title: "some title"}
    @update_attrs %{author: "some updated author", body: "some updated body", published_at: ~N[2011-05-18 15:01:01], title: "some updated title"}
    @invalid_attrs %{author: nil, body: nil, published_at: nil, title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blog.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Blog.create_post(@valid_attrs)
      assert post.author == "some author"
      assert post.body == "some body"
      assert post.published_at == ~N[2010-04-17 14:00:00]
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Blog.update_post(post, @update_attrs)
      assert post.author == "some updated author"
      assert post.body == "some updated body"
      assert post.published_at == ~N[2011-05-18 15:01:01]
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end
end
