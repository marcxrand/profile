[
  attribute_formatters: %{class: ProfileWeb.TailwindFormatter},
  import_deps: [:ecto, :ecto_sql, :oban_web, :phoenix],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"],
  plugins: [Phoenix.LiveView.HTMLFormatter, Quokka],
  subdirectories: ["priv/*/migrations"]
]
