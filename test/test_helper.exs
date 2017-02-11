Code.require_file "http_client.exs", __DIR__
ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Rumbl.Repo, :manual)
