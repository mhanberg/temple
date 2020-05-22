defmodule TempleDemoWeb.TempleFeatureTest do
  use ExUnit.Case
  use Wallaby.Feature

  feature "renders the homepage", %{session: session} do
    session
    |> visit("/")
    |> assert_text("Welcome to Phoenix!")
  end
end
