defmodule PdfUploader.UploadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PdfUploader.Uploads` context.
  """

  @doc """
  Generate a upload.
  """
  def upload_fixture(attrs \\ %{}) do
    {:ok, upload} =
      attrs
      |> Enum.into(%{
        filename: "some filename"
      })
      |> PdfUploader.Uploads.create_upload()

    upload
  end
end
