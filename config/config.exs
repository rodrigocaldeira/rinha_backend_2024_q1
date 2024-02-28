# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :rinha_backend_2024_q1,
  namespace: RinhaBackend,
  ecto_repos: [RinhaBackend.Repo]

# Configures the endpoint
config :rinha_backend_2024_q1, RinhaBackendWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: RinhaBackendWeb.ErrorJSON],
    layout: false
  ],
  http: [
    port: {:system, "PORT"},
    compress: true,
    protocol_options: [
      idle_timeout: 60_000,
      max_keepalive: 100_000
    ],
    transport_options: [
      max_connections: 100_000,
      num_acceptors: 100,
      connection_type: :supervisor
    ]
  ]

# Configures Elixir's Logger
config :logger, :console, format: "$time $metadata[$level] $message\n"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
