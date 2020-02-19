defmodule Rumbl.MultimediaTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Multimedia
  alias Rumbl.Multimedia.Category

  describe "categories" do
    test "list_alphabetical_categories/0" do
      for name <- ~w(Z A B E C) do
        Multimedia.create_category!(name)
      end

      names =
        for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
          name
        end

      assert names == ~w(A B C E Z)
    end
  end

  describe "videos" do
    alias Rumbl.Multimedia.Video

    @valid_attrs %{description: "desc", title: "title", url: "url"}
    @update_attrs %{
      description: "updated desc",
      title: "updated title",
      url: "updated url"
    }
    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      owner = user_fixture()
      %Video{id: id1} = video_fixture(owner)
      assert [%Video{id: ^id1}] = Multimedia.list_videos()

      %Video{id: id2} = video_fixture(owner)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video!/1 returns the video with given id" do
      owner = user_fixture()
      %Video{id: id} = video_fixture(owner)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/2 with valid data creates a video" do
      owner = user_fixture()

      assert {:ok, video = %Video{}} = Multimedia.create_video(owner, @valid_attrs)
      assert video.description == "desc"
      assert video.title == "title"
      assert video.url == "url"
    end

    test "create_video/2 with invalid data returns error changeset" do
      owner = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert {:ok, video} = Multimedia.update_video(video, @update_attrs)
      assert video.description == "updated desc"
      assert video.title == "updated title"
      assert video.url == "updated url"
    end

    test "update_video/2 with invalid data returns error changeset" do
      owner = user_fixture()
      video = video_fixture(owner)
      id = video.id

      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert [] = Multimedia.list_videos()
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      owner = user_fixture()
      video = video_fixture(owner)

      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end
end
