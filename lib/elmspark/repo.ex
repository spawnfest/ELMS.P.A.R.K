defmodule Elmspark.Repo do
  use Ecto.Repo,
    otp_app: :elmspark,
    adapter: Ecto.Adapters.Postgres
end
