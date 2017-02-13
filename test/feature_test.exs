defmodule Rumbl.FeatureControllerTest do
  use Rumbl.ConnCase

  test "GET /feature", %{conn: conn} do
    conn = get conn, "/feature"
    assert html_response(conn, 200) =~ "Welcome to Feature!"
  end
end
