defmodule ThinkingAllowed.Repo do
  use Ecto.Repo,
    otp_app: :thinking_allowed,
    adapter: Ecto.Adapters.SQLite3
end
