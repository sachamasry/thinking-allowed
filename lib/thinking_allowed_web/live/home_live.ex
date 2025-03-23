defmodule ThinkingAllowedWeb.HomeLive do
  use ThinkingAllowedWeb, :live_view
  use ThinkingAllowedNative, :live_view


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :counter, 0)}
  end
end
