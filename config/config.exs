# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configure bun
config :bun,
  version: "1.3.3",
  assets: [args: [], cd: Path.expand("../assets", __DIR__)],
  css: [
    args: ~w(run tailwindcss --input=css/app.css --output=../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ],
  js: [
    args:
      ~w(build js/app.js --outdir=../priv/static/assets --external /fonts/* --external /images/*),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure oban
config :profile, Oban,
  engine: Oban.Pro.Engines.Smart,
  notifier: Oban.Notifiers.PG,
  plugins: [
    {
      Oban.Pro.Plugins.DynamicCron,
      crontab: [
        # {"* * * * *", MyApp.MinuteJob}
      ]
    },
    Oban.Pro.Plugins.DynamicLifeline,
    Oban.Pro.Plugins.DynamicPartitioner,
    Oban.Pro.Plugins.DynamicPrioritizer,
    {
      Oban.Pro.Plugins.DynamicQueues,
      queues: [default: 10], sync_mode: :automatic
    }
  ],
  repo: Profile.Repo

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :profile, Profile.Mailer, adapter: Swoosh.Adapters.Local

# Configure the repository
config :profile, Profile.Repo,
  migration_timestamps: [type: :utc_datetime_usec],
  types: Profile.PostgrexTypes

# Configure the endpoint
config :profile, ProfileWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ProfileWeb.ErrorHTML, json: ProfileWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Profile.PubSub,
  live_view: [signing_salt: "2S0fLDtp"]

config :profile,
  ecto_repos: [Profile.Repo],
  env: config_env(),
  generators: [timestamp_type: :utc_datetime_usec, binary_id: true]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
