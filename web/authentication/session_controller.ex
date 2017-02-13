defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller

  def new(conn, _) do
    render conn, "login.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Rumbl.Auth.login_by_username_and_password(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome Back!")
        |> redirect(to: home_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("login.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Rumbl.Auth.logout()
    |> redirect(to: home_path(conn, :index))
  end
end
