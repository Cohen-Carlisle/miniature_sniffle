defmodule MiniatureSniffle.Repo do
  use Ecto.Repo,
    otp_app: :miniature_sniffle,
    adapter: Ecto.Adapters.Postgres
end
