defmodule PdfUploaderWeb.UploadLive.Components.FileListTest do
  use PdfUploaderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenix.Component

  alias PdfUploaderWeb.UploadLive.Components.FileList

  describe "file list" do
    test "renders empty state when no files" do
      html =
        render_component(FileList,
          id: "file-list",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          },
          uploaded_files: []
        )

      assert html =~ "Nenhum arquivo selecionado"
    end

    test "renders files in progress" do
      html =
        render_component(FileList,
          id: "file-list",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [
              %Phoenix.LiveView.UploadEntry{
                client_name: "test.pdf",
                progress: 50,
                ref: "abc"
              }
            ],
            errors: []
          },
          uploaded_files: []
        )

      assert html =~ "test.pdf"
      assert html =~ "50%"
      assert html =~ "Enviando..."
      assert html =~ "width: 50%"
    end

    test "renders uploaded files" do
      now = DateTime.utc_now()

      html =
        render_component(FileList,
          id: "file-list",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          },
          uploaded_files: [
            %{name: "completed.pdf", timestamp: now}
          ]
        )

      assert html =~ "completed.pdf"
      assert html =~ "Enviado"
      assert html =~ Calendar.strftime(now, "%H:%M")
    end

    test "renders both in progress and uploaded files" do
      now = DateTime.utc_now()

      html =
        render_component(FileList,
          id: "file-list",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [
              %Phoenix.LiveView.UploadEntry{
                client_name: "uploading.pdf",
                progress: 75,
                ref: "abc"
              }
            ],
            errors: []
          },
          uploaded_files: [
            %{name: "completed.pdf", timestamp: now}
          ]
        )

      assert html =~ "uploading.pdf"
      assert html =~ "75%"
      assert html =~ "completed.pdf"
      assert html =~ "Enviado"
    end

    test "applies custom classes" do
      html =
        render_component(FileList,
          id: "file-list",
          upload: %Phoenix.LiveView.UploadConfig{
            ref: "123",
            entries: [],
            errors: []
          },
          uploaded_files: [],
          class: "custom-class"
        )

      assert html =~ "custom-class"
    end
  end
end
