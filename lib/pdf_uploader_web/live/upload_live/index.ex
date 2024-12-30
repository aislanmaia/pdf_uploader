defmodule PdfUploaderWeb.UploadLive.Index do
  use PdfUploaderWeb, :live_view

  alias PdfUploader.Uploads
  alias PdfUploader.Uploads.Upload

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :uploads, Uploads.list_uploads())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Upload")
    |> assign(:upload, Uploads.get_upload!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Upload")
    |> assign(:upload, %Upload{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Uploads")
    |> assign(:upload, nil)
  end

  @impl true
  def handle_info({PdfUploaderWeb.UploadLive.FormComponent, {:saved, upload}}, socket) do
    {:noreply, stream_insert(socket, :uploads, upload)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    upload = Uploads.get_upload!(id)
    {:ok, _} = Uploads.delete_upload(upload)

    {:noreply, stream_delete(socket, :uploads, upload)}
  end
end
