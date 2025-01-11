defmodule PdfUploaderWeb.UploadLive.Components.UploadArea do
  use Phoenix.Component

  @doc """
  Renders the upload area container.

  ## Props

    * `class` - Optional string of additional CSS classes.
    * `title` - Optional string for the area title. Defaults to "Upload de PDFs".
    * `can_clear` - Optional boolean to determine if clear button should be enabled. Defaults to false.
    * `on_clear` - Optional function to be called when clear button is clicked.
    * `inner_block` - Required. The content to be rendered inside the upload area.

  ## Examples

      <.upload_area title="Upload de PDFs" can_clear={has_files?} on_clear={clear_fn}>
        Content goes here...
      </.upload_area>
  """
  attr :class, :string, default: nil
  attr :title, :string, default: "Upload de PDFs"
  attr :can_clear, :boolean, default: false
  attr :on_clear, :any, default: nil
  slot :inner_block, required: true

  def upload_area(assigns) do
    ~H"""
    <div class={[
      "w-[400px] border-r border-gray-200 bg-gray-50 p-6 flex flex-col gap-6",
      @class
    ]}>
      <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold text-gray-900"><%= @title %></h2>
        <button type="button" 
                class="text-sm text-red-600 hover:text-red-700 disabled:text-red-300"
                phx-click={@on_clear}
                disabled={!@can_clear}>
          Limpar Tudo
        </button>
      </div>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
