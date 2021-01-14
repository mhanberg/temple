defmodule Temple.Buffer do
  @moduledoc false

  use Agent

  defmodule State do
    defstruct contents: [], assigns: nil
  end

  def start_link(state \\ %State{contents: [], assigns: nil}) do
    Agent.start_link(fn -> state end)
  end

  def put(buffer, {:assigns, assigns}) do
    Agent.update(buffer, fn state ->
      %State{state | assigns: assigns}
    end)
  end

  def put(buffer, {:content, value}) do
    Agent.update(buffer, fn %State{contents: contents} = state ->
      %State{
        state
        | contents: [value | contents]
      }
    end)
  end

  def put(buffer, value) do
    put(buffer, {:contents, value})
  end

  def remove_new_line(buffer) do
    Agent.update(buffer, fn
      %State{contents: ["\n" | rest]} = state ->
        %State{
          state
          | contents: rest
        }

      %State{} = state ->
        state
    end)
  end

  def get(buffer, opts \\ []) do
    contents =
      buffer
      |> Agent.get(& &1.contents)
      |> Enum.reverse()
      |> Enum.join()
      |> String.trim()

    assigns =
      buffer
      |> Agent.get(& &1.assigns)

    if opts[:stop], do: stop(buffer)

    {contents, assigns}
  end

  def stop(buffer) do
    Agent.stop(buffer)
  end
end
