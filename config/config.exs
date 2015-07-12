use Mix.Config

level = if System.get_env("DEBUG") do
  :debug
else
  :info
end

config :logger, :console,
  level: level,
  format: "$date $time [$level] $metadata$message\n"
