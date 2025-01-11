defmodule PdfUploaderWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    active_nav_item =
      case socket.view do
        PdfUploaderWeb.UploadLive -> :uploads
        _ -> nil
      end

    {:cont, assign(socket, active_nav_item: active_nav_item)}
  end
end
