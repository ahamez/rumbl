defmodule Rumbl.AccountsTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "register_user/1" do
    @valid_attrs %{
      name: "User",
      username: "wall-e",
      password: "password"
    }

    @invalid_attrs %{}

    test "with valid data inserts user" do
      assert {:ok, user = %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert user.name == "User"
      assert user.username == "wall-e"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do
      assert {:error, _changeset} = Accounts.register_user(@invalid_attrs)
      assert [] = Accounts.list_users()
    end

    test "enforces unique usernames" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)

      assert %{username: [errors]} = errors_on(changeset)
      assert :unique = Keyword.get(errors, :constraint)

      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "does not accept long usernames" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
      {:error, changeset} = Accounts.register_user(attrs)

      assert %{username: [errors]} = errors_on(changeset)
      assert Keyword.equal?([count: 20, validation: :length, kind: :max, type: :string], errors)
    end

    test "requires password to be a least 6 chars long" do
      attrs = Map.put(@valid_attrs, :password, "123")
      {:error, changeset} = Accounts.register_user(attrs)

      assert %{password: [errors]} = errors_on(changeset)
      assert Keyword.equal?([count: 6, validation: :length, kind: :min, type: :string], errors)
    end
  end

  describe "authenticate_by_username_and_pass/2" do
    @pass "123456"

    setup do
      {:ok, user: user_fixture(password: @pass)}
    end

    test "returns user with correct password", %{user: user} do
      assert {:ok, auth_user} = Accounts.authenticate_by_username_and_pass(user.username, @pass)
      assert auth_user.id == user.id
    end

    test "returns unauthorized error with invalid password", %{user: user} do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_username_and_pass(user.username, "badpass")
    end

    test "returns not found error with no matching user" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_username_and_pass("unregistered user", @pass)
    end
  end
end
