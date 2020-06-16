defmodule Temple.Buffer do
  @moduledoc false
  def start_link(state \\ []) do
    Agent.start_link(fn -> state end)
  end

  def put(buffer, value) do
    Agent.update(buffer, fn b -> [value | b] end)
  end

  def remove_new_line(buffer) do
    Agent.update(buffer, fn
      ["\n" | rest] ->
        rest

      rest ->
        rest
    end)
  end

  def get(buffer) do
    buffer
    |> Agent.get(& &1)
    |> Enum.reverse()
    |> Enum.join()
    |> String.trim()
  end

  def stop(buffer) do
    Agent.stop(buffer)
  end
end
