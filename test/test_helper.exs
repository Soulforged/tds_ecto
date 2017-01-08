Logger.configure(level: :error)
ExUnit.start exclude: [:assigns_id_type, :array_type, :case_sensitive]

Application.put_env(:ecto, :lock_for_update, "FOR UPDATE")
Application.put_env(:ecto, :primary_key_type, :id)

# Basic test repo
Code.require_file "../deps/ecto/integration_test/support/repo.exs", __DIR__
Code.require_file "../deps/ecto/integration_test/support/types.exs", __DIR__
Code.require_file "../deps/ecto/integration_test/support/schemas.exs", __DIR__
Code.require_file "../deps/ecto/integration_test/support/migration.exs", __DIR__

alias Ecto.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
  filter_null_on_unique_indexes: true,
  adapter: Tds.Ecto,
  hostname: "mssql.local",
  #instance: "soulcage",
  username: "mssql",
  password: "mssql",
  database: "ecto_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10)

defmodule Ecto.Integration.TestRepo do
  use Ecto.Integration.Repo,
    otp_app: :ecto
end

defmodule Ecto.Integration.Case do
  use ExUnit.CaseTemplate

  alias Ecto.Integration.TestRepo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end
end

:erlang.system_flag :backtrace_depth, 50

#_   = Tds.Ecto.storage_down(TestRepo.config)
#:ok = Tds.Ecto.storage_up(TestRepo.config)

{:ok, pid} = TestRepo.start_link

# :ok = Ecto.Migrator.up(TestRepo, 0, Ecto.Integration.Migration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
Process.flag(:trap_exit, true)
