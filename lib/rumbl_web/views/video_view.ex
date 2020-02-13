defmodule RumblWeb.VideoView do
  use RumblWeb, :view

  def category_select_options(categories) do
    for c <- categories, do: {c.name, c.id}
  end
end
