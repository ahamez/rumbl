defmodule RumblWeb.UserView do
  use RumblWeb, :view

  alias Rumbl.Accounts

  def transmogrify(%Accounts.User{name: name}) do
    name <> Enum.random(["👍", "👔", "⚠️", "🔑", "🦖", "🐱", "🦉"])
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end
end
