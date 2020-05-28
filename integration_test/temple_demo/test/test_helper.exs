ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(TempleDemo.Repo, :manual)

Application.put_env(:wallaby, :base_url, TempleDemoWeb.Endpoint.url)

{:ok, _} = Application.ensure_all_started(:wallaby)
