defmodule Rumbl.UserControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.User

  @valid_attrs %{name: "tester1", username: "tester1",
  password: "somepassword"}
  @invalid_attrs %{name: "tester1"}

  defp user_count(query) do
    Repo.one(from v in query,
    select: count(v.id))
  end

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user1 = insert_user(username: username)

      conn = assign(build_conn(), :current_user, user1)
      {:ok, conn: conn, user: user1}
    else
      :ok
    end
  end

  @tag login_as: "tester1"
  test "when logged in shows all users", %{conn: conn, user: user} do
    insert_user(username: "tester2")
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ user.username
  end

  @tag login_as: "tester1"
  test "can view own user details", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :show, user.id)
    assert html_response(conn, 200) =~ "#{user.id}"
  end

  test "new returns user form", %{conn: conn}  do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Create User"
  end

  test "create user and redirect", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by!(User, %{name: "tester1", username: "tester1"})
  end

  test "does not create user and renders errors when invalid", %{conn: conn} do
    count_before = user_count(User)
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert user_count(User) == count_before
  end

  test "requires user authentication on index and show", %{conn: conn} do
    Enum.each([
      get(conn, user_path(conn, :index)),
      get(conn, user_path(conn, :show, "123"))
      ], fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end)
  end
end
