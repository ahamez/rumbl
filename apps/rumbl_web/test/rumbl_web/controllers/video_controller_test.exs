defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase, async: true

  @create_attrs %{
    url: "http://example.com",
    title: "yup",
    description: "go away"
  }
  @invalid_attrs %{title: "invalid"}

  describe "without a logged-in user" do
    test "requires user authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.video_path(conn, :new)),
          get(conn, Routes.video_path(conn, :index)),
          get(conn, Routes.video_path(conn, :show, "999")),
          get(conn, Routes.video_path(conn, :edit, "345")),
          get(conn, Routes.video_path(conn, :update, "128", %{})),
          get(conn, Routes.video_path(conn, :create, %{})),
          get(conn, Routes.video_path(conn, :delete, "726"))
        ],
        fn conn ->
          assert html_response(conn, 302)
          assert conn.halted
        end
      )
    end

    test "authorizes actions against access by other users", %{conn: conn} do
      owner = user_fixture(username: "owner")
      video = video_fixture(owner, @create_attrs)
      non_owner = user_fixture(username: "other")
      conn = assign(conn, :current_user, non_owner)

      assert_error_sent :not_found, fn ->
        get(conn, Routes.video_path(conn, :show, video))
      end

      assert_error_sent :not_found, fn ->
        get(conn, Routes.video_path(conn, :edit, video))
      end

      assert_error_sent :not_found, fn ->
        get(conn, Routes.video_path(conn, :update, video, video: @create_attrs))
      end

      assert_error_sent :not_found, fn ->
        get(conn, Routes.video_path(conn, :delete, video))
      end
    end
  end

  describe "with a logged-in user" do
    alias Rumbl.Multimedia
    alias Rumbl.Multimedia.Category

    defp video_count() do
      Enum.count(Multimedia.list_videos())
    end

    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    # used in setup/1 above
    @tag login_as: "foo"
    test "list all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "lolcat")
      other_video = video_fixture(user_fixture(username: "someone else"), title: "no lolcat")

      conn = get(conn, Routes.video_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    @tag login_as: "babar"
    test "creates user video and redirects", %{conn: conn, user: user} do
      %Category{id: category_id} = category_fixture("cat")
      attrs = Map.put(@create_attrs, :category_id, category_id)

      create_conn = post(conn, Routes.video_path(conn, :create), video: attrs)

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == Routes.video_path(create_conn, :show, id)

      conn = get(conn, Routes.video_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Video"

      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "conan"
    test "does not create videos, renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn = post(conn, Routes.video_path(conn, :create), video: @invalid_attrs)
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end
end
