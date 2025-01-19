defmodule PdfUploaderWeb.UploadLiveTest do
  use PdfUploaderWeb.ConnCase

  import Phoenix.LiveViewTest

  @upload_dir "priv/static/uploads"

  setup do
    on_exit(fn ->
      # Cleanup uploaded files after each test
      File.rm_rf!(@upload_dir)
      File.mkdir_p!(@upload_dir)
    end)
  end

  describe "Upload" do
    test "renders upload form", %{conn: conn} do
      {:ok, view, html} = live(conn, "/upload")

      assert html =~ "Upload de PDFs"
      assert html =~ "Arraste seus arquivos PDF aqui"
      assert view |> element("form") |> has_element?()
    end

    test "handles valid PDF upload", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/upload")

      file = %{
        name: "test.pdf",
        content: "PDF content",
        type: "application/pdf"
      }

      upload = file_input(view, "#upload-form", :pdf_files, [file])
      assert render_upload(upload, "test.pdf", 100) =~ "100%"

      assert view
             |> element("button[type='submit']")
    end

    test "handles mode switching", %{conn: conn} do
      {:ok, view, html} = live(conn, "/upload")

      # Default mode should be file
      assert html =~ "data-mode-selected=\"file\""

      # Switch to folder mode
      render_click(view, "switch-mode", %{"mode" => "folder"})

      assert render(view) =~ "data-mode-selected=\"folder\""
    end

    test "handles files panel toggling", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/upload")

      # Verify initial state
      assert view |> element("button", "Mostrar Arquivos") |> has_element?()

      # Perform the toggle action
      view |> element("button", "Mostrar Arquivos") |> render_click()

      # Verify the updated state
      assert render(view) =~ ~r/Arquivos/
    end

    test "handles upload cancellation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/upload")

      file = %{
        name: "test.pdf",
        content: "PDF content",
        type: "application/pdf"
      }

      upload = file_input(view, "#upload-form", :pdf_files, [file])
      assert render_upload(upload, "test.pdf", 54) =~ ~r/\d+%/

      # Get the reference after the upload is prepared
      %{"ref" => ref} = Enum.at(upload.entries, 0)

      # Test the click on item to cancel its upload
      assert view
             |> element("button[phx-click='cancel-upload'][phx-value-ref='#{ref}']")
             |> render_click()

      # Verify the cancellation
      refute has_element?(view, "#upload-#{ref}")
    end

    test "handles clear uploads", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/upload")

      upload = file_input(view, "form", :pdf_files, [
        %{
          last_modified: 1_594_171_879_000,
          name: "sample.pdf",
          content: "PDF content",
          size: byte_size("PDF content"),
          relative_path: "sample.pdf",
          type: "application/pdf"
        }
      ])

      assert render_upload(upload, "sample.pdf", 100) =~ "100%"

      # Save the uploaded files
      render_click(view, :save)

      # Verify the uploads are saved
      assert render(view) =~ "Enviado"

      # Clear uploads
      assert view
      |> element("button[phx-click='clear-uploads']")
      |> render_click()

      # Verify the uploads are cleared
      assert render(view) =~ "Nenhum arquivo selecionado"
    end

    test "validates file type", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/upload")

      file = %{
        name: "test.txt",
        content: "text content",
        type: "text/plain"
      }

      upload = file_input(view, "#upload-form", :pdf_files, [file])
      {:error, [[_, :not_accepted]]} = render_upload(upload, "test.txt")
    end
  end
end
