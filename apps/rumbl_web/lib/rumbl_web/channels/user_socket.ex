defmodule RumblWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  @max_age 60 * 60 * 24 * 7

  # Channels
  channel "videos:*", RumblWeb.VideoChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, reason} ->
        Logger.info("#{inspect(reason)}")
        :error
    end
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

  def id(socket) do
    "user_socket:#{socket.assigns.user_id}"
  end
end
