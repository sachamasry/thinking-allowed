defmodule ThinkingAllowedWeb.Layouts.SwiftUI do
  use ThinkingAllowedNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
