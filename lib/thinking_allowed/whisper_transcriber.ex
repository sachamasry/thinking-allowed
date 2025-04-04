defmodule ThinkingAllowed.WhisperTranscriber do
  @moduledoc """
  Speech-to-text transcription using Bumblebee and Whisper model
  """

  def load_model(model_variant \\ :base) do
    {:ok, whisper} = Bumblebee.load_model({:hf, "openai/whisper-large-v3-turbo", offline: true})

    {:ok, featurizer} =
      Bumblebee.load_featurizer({:hf, "openai/whisper-large-v3-turbo", offline: true})

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "openai/whisper-large-v3-turbo", offline: true})

    {:ok, generation_config} =
      Bumblebee.load_generation_config({:hf, "openai/whisper-large-v3-turbo", offline: true})

    %{
      whisper: whisper,
      featurizer: featurizer,
      tokenizer: tokenizer,
      generation_config: generation_config
    }
  end

  def serving() do
    %{
      whisper: whisper,
      featurizer: featurizer,
      tokenizer: tokenizer,
      generation_config: generation_config
    } = load_model("large-v3-turbo")

    serving =
      Bumblebee.Audio.speech_to_text_whisper(whisper, featurizer, tokenizer, generation_config,
        chunk_num_seconds: 30,
        client_batch_size: 1,
        compile: [batch_size: 1],
        task: :transcribe,
        defn_options: [compiler: EXLA],
        timestamps: :segments
        # stream: true
      )
  end

  def transcribe(audio_path, opts \\ []) do
    # model_variant = Keyword.get(opts, :model, :base)
    # language = Keyword.get(opts, :language, "en")

    # %{model: model, featurizer: featurizer, tokenizer: tokenizer} = load_model(model_variant)

    # Load and process audio
    # {:ok, audio} = Nx.Audio.read(audio_path)
    # preprocessed = Bumblebee.Audio.prepare_whisper_input(audio, featurizer)

    # Run transcription
    # %{results: transcription} =
    #   Bumblebee.Audio.speech_to_text(
    #     preprocessed,
    #     model,
    #     tokenizer,
    #     language: language
    #   )

    # transcription

    # output = Nx.Serving.run(serving(), {:file, audio_path})
  end

  def start_link(_opts) do
    serving = serving()

    Nx.Serving.start_link(serving: serving, name: __MODULE__, batch_timeout: 100)
  end
end
