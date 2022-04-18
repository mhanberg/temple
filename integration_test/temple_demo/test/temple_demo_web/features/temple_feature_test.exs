defmodule TempleDemoWeb.TempleFeatureTest do
  use ExUnit.Case, async: false
  use Wallaby.Feature
  alias TempleDemoWeb.Router.Helpers, as: Routes
  @endpoint TempleDemoWeb.Endpoint

  feature "renders the homepage", %{session: session} do
    session
    |> visit("/")
    |> assert_text("Welcome to Phoenix!")
    |> assert_text("inner content of outer")
  end

  feature "case statements work", %{session: session} do
    session
    |> visit("/?text=staging")
    |> assert_text("Welcome to Phoenix!")
    |> assert_text("Peace-of-mind from prototype to staging")
    |> visit("/?text=foobar")
    |> assert_text("Welcome to Phoenix!")
    |> assert_text("Peace-of-mind from prototype to production")
  end

  feature "can create a new post", %{session: session} do
    session
    |> visit(Routes.post_path(@endpoint, :index))
    |> click(Query.link("New Post"))
    |> fill_in(Query.text_field("Title"), with: "Temple is awesome!")
    |> fill_in(Query.text_field("Body"), with: "In this post I will show you how to use Temple")
    |> find(Query.select("post_published_at_year"), fn s ->
      s |> click(Query.option("2020"))
    end)
    |> find(Query.select("post_published_at_month"), fn s ->
      s |> click(Query.option("May"))
    end)
    |> find(Query.select("post_published_at_day"), fn s ->
      s |> click(Query.option("21"))
    end)
    |> fill_in(Query.text_field("Author"), with: "Mitchelob Ultra")
    |> assert_has(Query.css("#disabled-input[disabled]"))
    |> click(Query.button("Save"))
    |> assert_text("Post created successfully.")
  end

  feature "can create empty tags", %{session: session} do
    one_empty_span = Query.css("span:empty", visible: false)

    session
    |> visit(Routes.post_path(@endpoint, :index))
    |> assert_has(one_empty_span)
  end
end
