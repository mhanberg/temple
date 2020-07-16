defmodule Temple.Recompiler do
  defmacro __using__(_) do
    quote do
      component_path = Application.get_env(:temple, :components_path)

      for f <- File.ls!(component_path),
          do:
            Module.put_attribute(
              __MODULE__,
              :external_resource,
              Path.join(component_path, f)
            )
    end
  end
end
