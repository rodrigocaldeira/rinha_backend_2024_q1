defmodule RinhaBackend.Repo do
  use Ecto.Repo,
    otp_app: :rinha_backend_2024_q1,
    adapter: Ecto.Adapters.Postgres
end
