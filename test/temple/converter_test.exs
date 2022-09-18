defmodule Temple.ConverterTest do
  use ExUnit.Case, async: true

  alias Temple.Converter

  describe "convert/1" do
    test "converts basic html" do
      # html
      html = """
      <div class="container" disabled aria-label="alice">
        <!-- this is a comment -->
        I'm some content!
      </div>
      """

      assert Converter.convert(html) ===
               """
               div class: "container", disabled: true, aria_label: "alice" do
                 #  this is a comment 

                 "I'm some content!"
               end
               """
               |> String.trim()
    end

    test "multiline html comments" do
      # html
      html = """
      <div >
        <!-- this is a comment
        and this is some multi

        stuff -->
      </div>
      """

      assert Converter.convert(html) ===
               """
               div do
                 #  this is a comment
                 #   and this is some multi

                 #   stuff 
               end
               """
               |> String.trim()
    end

    test "script and style tag" do
      # html
      html = """
        <script>
          console.log("ayy yoo");
        </script>

        <style>
          .foo {
            color: red;
          }
        </style>
      """

      assert Converter.convert(html) ===
               """
               script do
                 "console.log(\\"ayy yoo\\");"
               end

               style do
                 ".foo {"
                 "color: red;"
                 "}"
               end
               """
               |> String.trim()
    end
  end
end
