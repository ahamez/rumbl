# Rumbl

Project from the "Programming with Phœnix" book.

# Differences

`rumbl/lib/rumbl_web/views/user_view.ex`
Used a `transmogrify` function rather than `first_name`
```
def transmogrify(%Accounts.User{name: name}) do
  name <> Enum.random(["👍", "👔", "⚠️", "🔑", "🦖", "🐱", "🦉"])
end
```

Show category in `/manage/videos`
```
def show(conn, %{"id" => id}, current_user) do
  video =
    current_user
    |> Multimedia.get_user_video!(id)
    |> Rumbl.Repo.preload(:category)

  render(conn, "show.html", video: video)
end
```
```
  <li>
    <strong>Category:</strong>
    <%=
      @video.category.name
    %>
  </li>
```

`data_case.ex`
Don't test string for errors
```
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {_message, opts} ->
      opts
    end)
  end
```
