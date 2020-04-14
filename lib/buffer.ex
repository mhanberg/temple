defmodule Temple.Buffer do
  def start_link(state \\ []) do
    Agent.start_link(fn -> state end)
  end

  def put(buffer, value) do
    Agent.update(buffer, fn b -> [value | b] end)
  end

  def get(buffer) do
    buffer
    |> Agent.get(& &1)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def stop(buffer) do
    Agent.stop(buffer)
  end
end
