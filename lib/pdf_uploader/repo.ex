defmodule PdfUploader.Repo do
  use Ecto.Repo,
    otp_app: :pdf_uploader,
    adapter: Ecto.Adapters.Postgres
end
