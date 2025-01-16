defmodule PdfUploaderWeb.UploadLive do
  use PdfUploaderWeb, :live_view

  import PdfUploaderWeb.UploadLive.Components.UploadArea

  @upload_dir "priv/static/uploads"

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:mode, :single)
     |> assign(:show_files_panel, false)
     |> allow_upload(:pdf_files, accept: ~w(.pdf), max_entries: 100, max_file_size: 10_000_000)}
  end

  def handle_event("switch-mode", %{"mode" => mode}, socket) do
    mode = String.to_existing_atom(mode)
    {:noreply, assign(socket, :mode, mode)}
  end

  def handle_event("validate", _params, socket) do
    case socket.assigns.uploads.pdf_files.errors do
      [] ->
        {:noreply, socket}

      [{_ref, error} | _] ->
        {:noreply, put_flash(socket, :error, error_to_string(error))}
    end
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :pdf_files, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :pdf_files, fn %{path: path}, entry ->
        # Define relative path based on selection mode
        relative_path =
          if entry.client_relative_path == "" do
            # For individual files, use only the filename
            entry.client_name
          else
            # For folders, maintain directory structure
            entry.client_relative_path
          end

        # Create necessary directories
        dest_path = Path.join(@upload_dir, relative_path)
        dest_dir = Path.dirname(dest_path)
        File.mkdir_p!(dest_dir)

        # Move file to destination directory
        File.cp!(path, dest_path)

        uploaded_file = %{
          name: entry.client_name,
          size: entry.client_size,
          timestamp: NaiveDateTime.local_now(),
          status: "completed",
          path: relative_path
        }

        {:ok, uploaded_file}
      end)

    socket =
      socket
      |> update(:uploaded_files, &(&1 ++ uploaded_files))
      |> put_flash(:info, "Files uploaded successfully!")

    {:noreply, socket}
  end

  def handle_event("clear-uploads", _params, socket) do
    # Cancel all pending uploads
    socket =
      Enum.reduce(socket.assigns.uploads.pdf_files.entries, socket, fn entry, acc ->
        cancel_upload(acc, :pdf_files, entry.ref)
      end)

    # Clear uploaded files list and reinitialize upload
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:pdf_files,
        accept: ~w(.pdf),
        max_entries: 100,
        max_file_size: 10_000_000
      )

    {:noreply, socket |> clear_flash()}
  end

  def handle_event("toggle-files-panel", _, socket) do
    {:noreply, assign(socket, show_files_panel: !socket.assigns.show_files_panel)}
  end

  def handle_info(:clear_flash, socket) do
    socket =
      socket
      |> clear_flash()

    {:noreply, socket}
  end

  def handle_info({:mode_changed, mode}, socket) do
    {:noreply, assign(socket, :mode, mode)}
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
