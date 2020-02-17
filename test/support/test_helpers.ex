defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "User",
        username: "user_#{System.unique_integer([:positive])}",
        password: attrs[:password] || "password"
      })
      |> Accounts.register_user()

    user
  end

  def video_fixture(user = %Accounts.User{}, attrs \\ %{}) do
    attrs =
      Enum.into(
        attrs,
        %{
          title: "Title",
          url: "http://example.com",
          description: "Description"
        }
      )

    {:ok, video} = Multimedia.create_video(user, attrs)

    video
  end

  def category_fixture(name \\ "category") do
    Multimedia.create_category!(name)
  end
end
