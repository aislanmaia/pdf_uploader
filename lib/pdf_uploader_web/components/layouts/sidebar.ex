defmodule PdfUploaderWeb.Components.Layouts.Sidebar do
  use Phoenix.LiveComponent

  import PdfUploaderWeb.CoreComponents
  import Phoenix.Component

  @default_nav_items [
    %{icon: "hero-document-plus", label: "Upload", path: "/upload", id: :uploads},
    %{icon: "hero-chart-bar", label: "Estatísticas", path: "#", id: :stats}
  ]

  @doc """
  Renders a sidebar navigation component.

  ## Props

    * `active_item` - Required. Atom indicating the currently active navigation item.
    * `class` - Optional string of additional CSS classes.
    * `nav_items` - Optional list of navigation items. Defaults to standard nav items.

  ## Examples

      <.live_component
        module={PdfUploaderWeb.Components.Layouts.Sidebar}
        id="sidebar"
        active_item={:uploads}
      />
  """
  attr :active_item, :atom, required: true
  attr :class, :string, default: nil
  attr :nav_items, :list, default: @default_nav_items

  def render(assigns) do
    ~H"""
    <aside class={[
      "w-16 bg-white border-r border-gray-200 flex flex-col items-center py-4 gap-6",
      @class
    ]}>
      <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
        <.icon name="hero-document" class="w-6 h-6 text-purple-600" />
      </div>

      <nav class="flex flex-col gap-4" aria-label="Sidebar">
        <%= for item <- @nav_items do %>
          <.link
            navigate={item.path}
            class={[
              "w-10 h-10 rounded-lg flex items-center justify-center",
              @active_item == item.id && "bg-purple-50 text-purple-600" || "hover:bg-gray-100 text-gray-500"
            ]}
            aria-current={if @active_item == item.id, do: "page"}
          >
            <.icon name={item.icon} class="w-5 h-5" />
            <span class="sr-only"><%= item.label %></span>
          </.link>
        <% end %>
      </nav>
    </aside>
    """
  end
end
