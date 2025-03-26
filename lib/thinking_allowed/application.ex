defmodule ThinkingAllowed.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # {:ok, whisper} = Bumblebee.load_model({:hf, "openai/whisper-large-v3-turbo"})
    # {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "openai/whisper-large-v3-turbo"})
    # {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/whisper-large-v3-turbo"})

    # {:ok, generation_config} =
    #   Bumblebee.load_generation_config({:hf, "openai/whisper-large-v3-turbo"})

    # serving =
    #   Bumblebee.Audio.speech_to_text_whisper(whisper, featurizer, tokenizer, generation_config,
    #     chunk_num_seconds: 30,
    #     client_batch_size: 1,
    #     task: :transcribe,
    #     defn_options: [compiler: EXLA]
    #   )

    children = [
      # {Nx.Serving, name: WhisperServing, serving: serving},
      ThinkingAllowedWeb.Telemetry,
      ThinkingAllowed.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:thinking_allowed, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:thinking_allowed, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ThinkingAllowed.PubSub},
      # Start a worker by calling: ThinkingAllowed.Worker.start_link(arg)
      # {ThinkingAllowed.Worker, arg},
      # Start to serve requests, typically the last entry
      ThinkingAllowedWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThinkingAllowed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThinkingAllowedWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
