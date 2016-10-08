# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures Ecto repos
config :hitchcock,
  namespace: Hitchcock,
  ecto_repos: [Hitchcock.Repo]

# Configures the endpoint
config :hitchcock, Hitchcock.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "uRO/hQb2wFkD2TxKq6jadnCYK0jlN93WvtlClHsNxM6SX564sPI5xm7kC5KB/CFb",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Hitchcock.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Configures Guardian
config :guardian, Guardian,
  issuer: "Hitchcock",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "j2sa9/qzu1W7p9I0Xu/4lcCJCMQigLgJWMVGTjph6L4TWDT3eKZmjYnOJoiiyjkf",
  serializer: Hitchcock.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
