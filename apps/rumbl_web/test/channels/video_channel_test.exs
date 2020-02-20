defmodule RumblWeb.Channels.VideoChannelTest do
  use RumblWeb.ChannelCase
  import RumblWeb.TestHelpers

  setup do
    user = insert_user(name: "Alf")
    video = insert_video(user, title: "Likes cats")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, user: user, video: video} do
    for body <- ~w(one two) do
      Rumbl.Multimedia.annotate_video(user, video.id, %{body: body, at: 0})
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new annotations", %{socket: socket, video: video} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push(socket, "new_annotation", %{body: "the body", at: 0})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "new annotations triggers InfoSys", %{socket: socket, video: video} do
    insert_user(
      username: "wolfram",
      password: "passpasspass"
    )

    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    ref = push(socket, "new_annotation", %{body: "1 + 1", at: 123})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "1 + 1", at: 123}
    assert_broadcast "new_annotation", %{body: "2", at: 123}
  end
end
