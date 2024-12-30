defmodule PdfUploaderWeb.UploadLive do
  use PdfUploaderWeb, :live_view

  @upload_dir "priv/static/uploads"

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:folder_mode, false)
     |> allow_upload(:pdf_files, accept: ~w(.pdf), max_entries: 100, max_file_size: 10_000_000)}
  end

  def handle_event("switch-mode", _params, socket) do
    # Envia o evento de volta para o hook
    {:noreply, push_event(socket, "switch-mode", %{})}
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
        # Define o caminho relativo baseado no modo de seleção
        relative_path =
          if entry.client_relative_path == "" do
            # Para arquivos individuais, usa apenas o nome do arquivo
            entry.client_name
          else
            # Para pastas, mantém a estrutura de diretórios
            entry.client_relative_path
          end

        # Cria os diretórios necessários
        dest_path = Path.join(@upload_dir, relative_path)
        dest_dir = Path.dirname(dest_path)
        File.mkdir_p!(dest_dir)

        # Move o arquivo para o diretório de destino
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
      |> put_flash(:info, "Arquivos enviados com sucesso!")

    {:noreply, socket}
  end

  def handle_event("clear-uploads", _params, socket) do
    # Cancela todos os uploads pendentes
    socket =
      Enum.reduce(socket.assigns.uploads.pdf_files.entries, socket, fn entry, acc ->
        cancel_upload(acc, :pdf_files, entry.ref)
      end)

    # Limpa a lista de arquivos enviados e reinicializa o upload
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

  def handle_info(:clear_flash, socket) do
    socket =
      socket
      |> clear_flash()

    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "Arquivo muito grande. O tamanho máximo é 10MB"
  defp error_to_string(:too_many_files), do: "Você pode enviar no máximo 5 arquivos por vez"

  defp error_to_string(:not_accepted),
    do: "Tipo de arquivo não permitido. Apenas PDFs são aceitos"
end
