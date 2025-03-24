defmodule ThinkingAllowedWeb.HomeLive do
  use ThinkingAllowedWeb, :live_view
  use ThinkingAllowedNative, :live_view


  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("navigate", %{"to" => path}, socket) do
    {:noreply, push_navigate(socket, to: path)}
  end
end
