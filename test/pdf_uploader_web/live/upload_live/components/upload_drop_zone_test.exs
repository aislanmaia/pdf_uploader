defmodule PdfUploaderWeb.UploadLive.Components.UploadDropZoneTest do
  use PdfUploaderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PdfUploaderWeb.UploadLive.Components.UploadDropZone

  describe "upload drop zone" do
    test "renders with default mode" do
      html =
        render_component(UploadDropZone,
          id: "upload-drop-zone",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          }
        )

      assert html =~ "Arraste seus arquivos PDF aqui"
      assert html =~ "Máximo 100 arquivos"
      assert html =~ "Arquivos"
      assert html =~ "Pasta"
      assert html =~ "Iniciar Upload"
      assert html =~ "disabled"
    end

    test "renders with file mode selected" do
      html =
        render_component(UploadDropZone,
          id: "upload-drop-zone",
          mode: :file,
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          }
        )

      assert html =~ "border-purple-500"
      assert html =~ "text-purple-600"
      assert html =~ "data-mode=\"file\""
    end

    test "renders with folder mode selected" do
      html =
        render_component(UploadDropZone,
          id: "upload-drop-zone",
          mode: :folder,
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          }
        )

      assert html =~ "data-mode=\"folder\""
    end

    test "enables submit button when there are entries and no errors" do
      upload_config = %Phoenix.LiveView.UploadConfig{
        ref: "123",
        entries: [
          %Phoenix.LiveView.UploadEntry{
            ref: "abc123",
            upload_ref: "123",
            progress: 0,
            client_name: "test.pdf"
          }
        ],
        errors: []
      }

      html =
        render_component(UploadDropZone,
          id: "upload-drop-zone",
          upload: upload_config
        )

      refute html =~ ~s(disabled="true")
    end

    test "disables submit button when there are errors" do
      html =
        render_component(UploadDropZone,
          id: "upload-drop-zone",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [%Phoenix.LiveView.UploadEntry{}],
            errors: [error: "some error"]
          }
        )

      assert html =~ "disabled"
    end
  end
end
