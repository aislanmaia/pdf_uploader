defmodule PdfUploaderWeb.UploadLive.Components.UploadAreaTest do
  use PdfUploaderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PdfUploaderWeb.UploadLive.Components.UploadArea

  test "renders upload area with default title" do
    html =
      render_component(&UploadArea.upload_area/1,
        id: "upload-area",
        inner_block: [%{
          inner_block: fn _, _ -> "Content" end
        }]
      )

    assert html =~ "Upload de PDFs"
    assert html =~ "Content"
    assert html =~ "disabled"
  end

  test "renders upload area with custom title" do
    html =
      render_component(&UploadArea.upload_area/1,
        id: "upload-area",
        title: "Custom Title",
        inner_block: [%{
          inner_block: fn _, _ -> "Content" end
        }]
      )

    assert html =~ "Custom Title"
  end

  test "renders clear button enabled when can_clear is true" do
    html =
      render_component(&UploadArea.upload_area/1,
        id: "upload-area",
        can_clear: true,
        inner_block: [%{
          inner_block: fn _, _ -> "Content" end
        }]
      )

    refute html =~ ~s(<button type="button" disabled)
    assert html =~ "Limpar Tudo"
  end

  test "applies custom classes" do
    html =
      render_component(&UploadArea.upload_area/1,
        id: "upload-area",
        class: "custom-class",
        inner_block: [%{
          inner_block: fn _, _ -> "Content" end
        }]
      )

    assert html =~ "custom-class"
  end
end
