defmodule PdfUploaderWeb.UploadLive.Components.FileList do
  use Phoenix.LiveComponent

  @doc """
  Renders a list of files being uploaded and already uploaded.

  ## Props

    * `id` - Required. The component ID.
    * `upload` - Required. The LiveView upload struct.
    * `uploaded_files` - Required list of uploaded files.
    * `on_cancel_upload` - Optional function to be called when an upload is cancelled.
    * `class` - Optional string of additional CSS classes.

  ## Examples

      <.live_component
        module={FileList}
        id="file-list"
        upload={@uploads.pdf_files}
        uploaded_files={@uploaded_files}
        on_cancel_upload="cancel-upload"
      />
  """
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:class, fn -> nil end)}
  end

  def render(assigns) do
    ~H"""
    <div class={["flex-1 min-h-0 bg-white rounded-xl border border-gray-200 flex flex-col", @class]}>
      <div class="p-4 border-b border-gray-200">
        <h3 class="text-sm font-medium text-gray-900">Arquivos</h3>
      </div>

      <div class="flex-1 overflow-y-auto p-4">
        <%= if Enum.empty?(@uploaded_files) and Enum.empty?(@upload.entries) do %>
          <div class="flex flex-col items-center justify-center h-full text-center">
            <svg class="w-8 h-8 text-gray-300 mb-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <path fill="currentColor" d="M20 6h-8l-2-2H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm0 12H4V8h16v10z" />
            </svg>
            <p class="text-sm text-gray-500">Nenhum arquivo selecionado</p>
          </div>
        <% else %>
          <div class="space-y-3">
            <!-- Arquivos em upload -->
            <%= for entry <- @upload.entries do %>
              <div class="p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-2 min-w-0">
                    <svg class="w-4 h-4 text-purple-600 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                      <path fill="currentColor" d="M8 16h8v2H8zm0-4h8v2H8zm6-10H6c-1.1 0-2 .9-2 2v16c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6z" />
                    </svg>
                    <span class="text-sm text-gray-900 truncate"><%= entry.client_name %></span>
                  </div>
                  <button type="button"
                          class="text-gray-400 hover:text-gray-600"
                          phx-click={@on_cancel_upload}
                          phx-value-ref={entry.ref}
                          phx-target={@myself}>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-1">
                  <div class="bg-purple-600 h-1 rounded-full transition-all" style={"width: #{entry.progress}%"}></div>
                </div>
                <div class="flex justify-between mt-2">
                  <span class="text-xs text-gray-500"><%= entry.progress %>%</span>
                  <span class="text-xs text-gray-500">Enviando...</span>
                </div>
              </div>
            <% end %>

            <!-- Arquivos enviados -->
            <%= for file <- @uploaded_files do %>
              <div class="p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2 min-w-0">
                    <svg class="w-4 h-4 text-green-600 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                      <path fill="currentColor" d="M8 16h8v2H8zm0-4h8v2H8zm6-10H6c-1.1 0-2 .9-2 2v16c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6z" />
                    </svg>
                    <span class="text-sm text-gray-900 truncate"><%= file.name %></span>
                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      <svg class="w-3 h-3 mr-1" viewBox="0 0 24 24">
                        <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                      </svg>
                      Enviado
                    </span>
                  </div>
                  <span class="text-xs text-gray-500">
                    <%= Calendar.strftime(file.timestamp, "%H:%M") %>
                  </span>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    send(self(), {:cancel_upload, ref})
    {:noreply, socket}
  end
end
