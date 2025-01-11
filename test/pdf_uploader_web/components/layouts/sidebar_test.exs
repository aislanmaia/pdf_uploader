defmodule PdfUploaderWeb.Components.Layouts.SidebarTest do
  use PdfUploaderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PdfUploaderWeb.Components.Layouts.Sidebar

  test "renders sidebar with default navigation items" do
    html =
      render_component(&Sidebar.render/1,
        id: "sidebar",
        active_item: :uploads,
        nav_items: [
          %{icon: "hero-document-plus", label: "Upload", path: "/upload", id: :uploads}
        ]
      )

    assert html =~ "hero-document-plus"
    assert html =~ "Upload"
    assert html =~ "/upload"
    assert html =~ "bg-purple-50"  # active item style
  end

  test "renders sidebar with custom navigation items" do
    html =
      render_component(&Sidebar.render/1,
        id: "sidebar",
        active_item: :custom,
        nav_items: [
          %{icon: "hero-home", label: "Home", path: "/", id: :home},
          %{icon: "hero-cog", label: "Settings", path: "/settings", id: :custom}
        ]
      )

    assert html =~ "hero-home"
    assert html =~ "Home"
    assert html =~ "hero-cog"
    assert html =~ "Settings"
    assert html =~ "bg-purple-50"  # active item style
  end

  test "applies custom classes" do
    html =
      render_component(&Sidebar.render/1,
        id: "sidebar",
        active_item: :uploads,
        class: "custom-class",
        nav_items: [
          %{icon: "hero-document-plus", label: "Upload", path: "/upload", id: :uploads}
        ]
      )

    assert html =~ "custom-class"
  end

  test "includes aria labels for accessibility" do
    html =
      render_component(&Sidebar.render/1,
        id: "sidebar",
        active_item: :uploads,
        nav_items: [
          %{icon: "hero-document-plus", label: "Upload", path: "/upload", id: :uploads}
        ]
      )

    assert html =~ ~s(aria-label="Sidebar")
    assert html =~ ~s(aria-current="page")
    assert html =~ ~s(class="sr-only">Upload</span)
  end
end
