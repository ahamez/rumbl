defmodule RumblWeb.UserView do
  use RumblWeb, :view

  alias Rumbl.Accounts

  def transmogrify(%Accounts.User{name: name}) do
    name <> Enum.random(["👍", "👔", "⚠️", "🔑", "🦖", "🐱", "🦉"])
  end
end
