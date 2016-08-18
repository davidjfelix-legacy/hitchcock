ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Hitchcock.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Hitchcock.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Hitchcock.Repo)

