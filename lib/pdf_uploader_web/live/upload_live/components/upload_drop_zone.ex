defmodule PdfUploaderWeb.UploadLive.Components.UploadDropZone do
  use Phoenix.LiveComponent

  @doc """
  Renders a drop zone for file uploads with mode switching.

  ## Props

    * `id` - Required. The component ID.
    * `upload` - Required. The LiveView upload struct.
    * `mode` - Optional atom. Either :file or :folder. Defaults to :file.
    * `on_mode_change` - Optional function to be called when mode is changed.
    * `class` - Optional string of additional CSS classes.

  ## Examples

      <.live_component
        module={UploadDropZone}
        id="upload-drop-zone"
        upload={@uploads.pdf_files}
        mode={@mode}
        on_mode_change="switch-mode"
      />
  """
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:mode, fn -> :file end)
     |> assign_new(:class, fn -> nil end)
     |> assign_new(:on_mode_change, fn -> nil end)}
  end

  def render(assigns) do
    ~H"""
    <form id="upload-form" phx-submit="save" phx-change="validate" class="flex flex-col gap-4">
      <div
        class="border-2 border-dashed border-gray-200 rounded-xl p-6 bg-white transition-colors hover:border-purple-500 hover:bg-gray-50"
        phx-drop-target={@upload.ref}
        id="upload-container"
        phx-hook="UploadHandler"
      >
        <div class="flex flex-col items-center gap-4">
          <div class="w-12 h-12 rounded-full bg-purple-50 flex items-center justify-center">
            <svg
              class="w-6 h-6 text-purple-600"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
            >
              <path
                fill="currentColor"
                d="M19.35 10.04A7.49 7.49 0 0 0 12 4C9.11 4 6.6 5.64 5.35 8.04A5.994 5.994 0 0 0 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5c0-2.64-2.05-4.78-4.65-4.96zM14 13v4h-4v-4H7l5-5l5 5h-3z"
              />
            </svg>
          </div>

          <div class="text-center">
            <p class="text-sm text-gray-600">Arraste seus arquivos PDF aqui ou</p>
            <p class="text-xs text-gray-400 mt-1">Máximo 100 arquivos</p>
          </div>

          <div class="w-full">
            <.live_file_input upload={@upload} class="hidden" />
            <div class="grid grid-cols-2 gap-3">
              <button
                type="button"
                class={[
                  "flex flex-col items-center justify-center p-3 border rounded-lg transition-colors group",
                  (@mode == :file && "border-purple-500 bg-purple-50") ||
                    "border-gray-200 hover:border-purple-500 hover:bg-purple-50"
                ]}
                phx-click={@on_mode_change}
                phx-value-mode="file"
                phx-target={@myself}
              >
                <svg
                  class={[
                    "w-5 h-5 transition-colors",
                    (@mode == :file && "text-purple-600") ||
                      "text-gray-400 group-hover:text-purple-600"
                  ]}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <span class={[
                  "text-xs font-medium mt-2 transition-colors",
                  (@mode == :file && "text-purple-600") || "text-gray-600 group-hover:text-purple-600"
                ]}>
                  Arquivos
                </span>
              </button>

              <button
                type="button"
                class={[
                  "flex flex-col items-center justify-center p-3 border rounded-lg transition-colors group",
                  (@mode == :folder && "border-purple-500 bg-purple-50") ||
                    "border-gray-200 hover:border-purple-500 hover:bg-purple-50"
                ]}
                phx-click={@on_mode_change}
                phx-value-mode="folder"
                phx-target={@myself}
              >
                <svg
                  class={[
                    "w-5 h-5 transition-colors",
                    (@mode == :folder && "text-purple-600") ||
                      "text-gray-400 group-hover:text-purple-600"
                  ]}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                  />
                </svg>
                <span class={[
                  "text-xs font-medium mt-2 transition-colors",
                  (@mode == :folder && "text-purple-600") ||
                    "text-gray-600 group-hover:text-purple-600"
                ]}>
                  Pasta
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <button
        type="submit"
        class="w-full px-4 py-2 bg-purple-600 text-white text-sm font-medium rounded-lg hover:bg-purple-700 transition-colors disabled:bg-purple-300 disabled:cursor-not-allowed"
        {if Enum.empty?(@upload.entries), do: [disabled: true], else: []}
      >
        Iniciar Upload
      </button>
    </form>
    """
  end

  def handle_event("switch-mode", %{"mode" => mode}, socket) do
    mode = String.to_existing_atom(mode)
    send(self(), {:mode_changed, mode})
    {:noreply, assign(socket, :mode, mode)}
  end
end
