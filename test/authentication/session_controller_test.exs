defmodule Rumbl.SessionControllerTest do
  use Rumbl.ConnCase

  @valid_attrs %{username: "tester", password: "password"}
  @invalid_attrs %{username: "tester", password: "nothis"}

  test "new returns login page", %{conn: conn}  do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "create session and redirect", %{conn: conn} do
    insert_user(username: "tester", password: "password")
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert redirected_to(conn) == home_path(conn, :index)
  end

  test "create session fails with no password", %{conn: conn} do
    insert_user(username: "tester", password: "password")
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert html_response(conn, 200) =~ "Login"
  end

  test "logout redirects to home", %{conn: conn} do
    insert_user(username: "tester", password: "password")
    post conn, session_path(conn, :create), session: @valid_attrs

    conn = delete conn, session_path(conn, :delete, 1)
    assert redirected_to(conn) == home_path(conn, :index)
  end
end
