defmodule Dsl.FormTest do
  use ExUnit.Case, async: true
  use Dsl

  describe "form_for" do
    test "returns a form tag" do
      conn = %Plug.Conn{}
      action = "/"

      {:safe, result} =
        htm do
          form_for(conn, action, [])
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{</form>}
    end

    test "can take a block" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            div()
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<div></div>}
      assert result =~ ~s{</form>}
    end

    test "can take a block that references the form" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            text_input(form, :bob)
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<input}
      assert result =~ ~s{type="text"}
      assert result =~ ~s{name="bob"}
      assert result =~ ~s{</form>}
    end
  end

  defmodule Person do
    use Ecto.Schema

    embedded_schema do
      field(:name)
      belongs_to(:company, Company)
      has_many(:responsibilities, Reponsibility)
    end
  end

  defmodule Company do
    use Ecto.Schema

    embedded_schema do
      field(:name)
      field(:field)
    end
  end

  defmodule Responsibility do
    use Ecto.Schema

    embedded_schema do
      field(:description)
    end
  end

  describe "inputs_for" do
    test "generates inputs for belongs_to" do
      person = %Person{company: %Company{}}
      changeset = Ecto.Changeset.change(person)
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for changeset, action, opts do
            text_input(form, :name)

            inputs_for form, :company do
              text_input(inner_form, :name)
              _ = "Bob"
              text_input(inner_form, :field)
            end
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<input}
      assert result =~ ~s{type="text"}
      assert result =~ ~s{name="person[company][name]"}
      assert result =~ ~s{name="person[company][field]"}
      assert result =~ ~s{</form>}
      refute result =~ ~s{Bob}
    end

    test "generates inputs for has_many" do
      person = %Person{responsibilities: [%Responsibility{}, %Responsibility{}]}
      changeset = Ecto.Changeset.change(person)
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for changeset, action, opts do
            text_input(form, :name)

            inputs_for form, :responsibilities do
              text_input(inner_form, :description)
              _ = "Bob"
            end
          end
        end

      assert result =~ ~s{<form}
      assert result =~ ~s{<input}
      assert result =~ ~s{type="text"}
      assert result =~ ~s{name="person[responsibilities][0][description]"}
      assert result =~ ~s{name="person[responsibilities][1][description]"}
      assert result =~ ~s{</form>}
      refute result =~ ~s{Bob}
    end
  end

  describe "helpers" do
    test "generates a checkbox input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            checkbox(form, :bob, class: "styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="checkbox"}
      assert result =~ ~s{class="styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a color input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            color_input(form, :bob, class: "styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="color"}
      assert result =~ ~s{class="styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a date input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            date_input(form, :bob, class: "date-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="date"}
      assert result =~ ~s{class="date-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a date select input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            date_select(form, :bob, class: "date-styles")
          end
        end

      assert result =~ ~s{<select}
    end

    test "generates a datetime_local_input input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            datetime_local_input(form, :bob, class: "date-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="datetime-local"}
      assert result =~ ~s{class="date-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a datetime_select input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            datetime_select(form, :bob, class: "datetime-select-styles")
          end
        end

      assert result =~ ~s{<select}
    end

    test "generates a email input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            email_input(form, :bob, class: "email-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="email"}
      assert result =~ ~s{class="email-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a file input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = [multipart: true]

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            file_input(form, :bob, class: "file-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="file"}
      assert result =~ ~s{class="file-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a hidden input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            hidden_input(form, :bob, class: "hidden-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="hidden"}
      assert result =~ ~s{class="hidden-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a number input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            number_input(form, :bob, class: "number-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="number"}
      assert result =~ ~s{class="number-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a password input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            password_input(form, :bob, class: "password-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="password"}
      assert result =~ ~s{class="password-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a range input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            range_input(form, :bob, class: "range-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="range"}
      assert result =~ ~s{class="range-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a search input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            search_input(form, :bob, class: "search-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="search"}
      assert result =~ ~s{class="search-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a telephone input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            telephone_input(form, :bob, class: "telephone-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="tel"}
      assert result =~ ~s{class="telephone-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a textarea" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            textarea(form, :bob, class: "textarea-styles")
          end
        end

      assert result =~ ~s{<textarea}
      assert result =~ ~s{class="textarea-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a time input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            time_input(form, :bob, class: "time-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="time"}
      assert result =~ ~s{class="time-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a time_select input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            time_select(form, :bob)
          end
        end

      assert result =~ ~s{<select}
    end

    test "generates a url input" do
      conn = %Plug.Conn{}
      action = "/"
      opts = []

      {:safe, result} =
        htm do
          form_for conn, action, opts do
            url_input(form, :bob, class: "url-styles")
          end
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="url"}
      assert result =~ ~s{class="url-styles"}
      assert result =~ ~s{name="bob"}
    end

    test "generates a reset input" do
      {:safe, result} =
        htm do
          reset("Reset", class: "reset-styles")
        end

      assert result =~ ~s{<input}
      assert result =~ ~s{type="reset}
      assert result =~ ~s{class="reset-styles"}
    end

    test "generates a submit/1 input" do
      {:safe, result} =
        htm do
          submit("Submit")
        end

      assert String.starts_with? result, ~s{<button}
      assert result =~ ~s{type="submit}
      assert result =~ ~s{Submit}
      assert String.ends_with? result, ~s{</button>}
    end

    test "generates a submit/1 input that takes a block" do
      {:safe, result} =
        htm do
          submit do
            text "Submit"
          end
        end

      assert String.starts_with? result, ~s{<button}
      assert result =~ ~s{type="submit}
      assert result =~ ~s{Submit}
      assert String.ends_with? result, ~s{</button>}
    end

    test "generates a submit/2 input that takes text and opts" do
      {:safe, result} =
        htm do
          submit("Submit", class: "btn")
        end

      assert String.starts_with? result, ~s{<button}
      assert result =~ ~s{type="submit}
      assert result =~ ~s{class="btn"}
      assert result =~ ~s{Submit}
      assert String.ends_with? result, ~s{</button>}
    end

    test "generates a submit/2 input that takes opts and a block" do
      {:safe, result} =
        htm do
          submit class: "btn" do
            text "Submit"
          end
        end

      assert String.starts_with? result, ~s{<button}
      assert result =~ ~s{type="submit}
      assert result =~ ~s{class="btn"}
      assert result =~ ~s{Submit}
      assert String.ends_with? result, ~s{</button>}
    end

    test "generates a phx_label/2 tag" do
      {:safe, result} =
        htm do
          phx_label(:user, :name)
        end

      assert result =~ ~s{<label}
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{Name}
      assert result =~ ~s{</label>}
    end

    test "generates a phx_label/3 with attrs" do
      {:safe, result} =
        htm do
          phx_label(:user, :name, class: "label-style")
        end

      assert result =~ ~s{<label}
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{class="label-style"}
      assert result =~ ~s{Name}
      assert result =~ ~s{</label>}
    end

    test "generates a phx_label/3 with text" do
      {:safe, result} =
        htm do
          phx_label(:user, :name, "Name")
        end

      assert result =~ ~s{<label}
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{Name}
      assert result =~ ~s{</label>}
    end

    test "generates a phx_label/3 with block" do
      {:safe, result} =
        htm do
          phx_label :user, :name do
            div do
              text "Name"
            end
          end
        end

      assert String.starts_with?(result, ~s{<label})
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{Name}
      assert String.ends_with?(result, ~s{</label>})
    end

    test "generates a phx_label/4 with text and opts" do
      {:safe, result} =
        htm do
          phx_label(:user, :name, "Name", class: "label-style")
        end

      assert result =~ ~s{<label}
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{class="label-style"}
      assert result =~ ~s{Name}
      assert result =~ ~s{</label>}
    end

    test "generates a phx_label/4 with block" do
      {:safe, result} =
        htm do
          phx_label :user, :name, class: "label-style" do
            div do
              text "Name"
            end
          end
        end

      assert String.starts_with?(result, ~s{<label})
      assert result =~ ~s{for="user_name"}
      assert result =~ ~s{class="label-style"}
      assert result =~ ~s{Name}
      assert String.ends_with?(result, ~s{</label>})
    end

    test "generates a multiple_select tag" do
      options = [
        Alice: 1,
        Bob: 2,
        Carol: 3
      ]

      {:safe, result} =
        htm do
          multiple_select(:user, :name, options, class: "label-style")
        end

      assert result =~ ~s{<select}
      assert result =~ ~s{name="user[name][]"}
      assert result =~ ~s{class="label-style"}
      assert result =~ ~s{multiple=""}
      assert result =~ ~s{<option}
      assert result =~ ~s{value="1"}
      assert result =~ ~s{Alice}
      assert result =~ ~s{value="2"}
      assert result =~ ~s{Bob}
      assert result =~ ~s{value="3"}
      assert result =~ ~s{Carol}
      assert result =~ ~s{</select>}
    end

    test "generates a select tag" do
      options = [
        Alice: 1,
        Bob: 2,
        Carol: 3
      ]

      {:safe, result} =
        htm do
          select :user, :name, options, class: "label-style"
        end

      assert result =~ ~s{<select}
      assert result =~ ~s{name="user[name]"}
      assert result =~ ~s{class="label-style"}
      assert result =~ ~s{<option}
      assert result =~ ~s{value="1"}
      assert result =~ ~s{Alice}
      assert result =~ ~s{value="2"}
      assert result =~ ~s{Bob}
      assert result =~ ~s{value="3"}
      assert result =~ ~s{Carol}
      assert result =~ ~s{</select>}

      refute result =~ ~s{multiple=""}
    end
  end
end
