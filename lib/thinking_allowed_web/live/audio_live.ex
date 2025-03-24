defmodule ThinkingAllowedWeb.AudioLive do
  use ThinkingAllowedWeb, :live_view
  use ThinkingAllowedNative, :live_view

  def render(assigns) do
    ~H"""
    <div>...</div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, recording: false, audio_url: nil)}
  end

  def handle_event("start_recording", _, socket) do
    {:noreply, assign(socket, recording: true, audio_url: nil)}
  end

  def handle_event("stop_recording", %{"audio_url" => audio_url}, socket) do
    {:noreply, assign(socket, recording: false, audio_url: audio_url)}
  end

  def handle_event("stop_recording", %{}, socket) do
    {:noreply, assign(socket, recording: false, audio_url: nil)}
  end

  def handle_event("delete_audio", _, socket) do
    {:noreply, assign(socket, audio_url: nil)}
  end
end
