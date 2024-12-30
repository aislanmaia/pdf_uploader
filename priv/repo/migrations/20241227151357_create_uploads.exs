defmodule PdfUploader.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :filename, :string

      timestamps(type: :utc_datetime)
    end
  end
end
