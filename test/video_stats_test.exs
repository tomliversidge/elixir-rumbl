defmodule Rumbl.VideoStatsTests do
  use ExUnit.Case
  alias Rumbl.VideoStream

  setup %{} do
    VideoStream.start_link()
    :ok
  end

  test "join joins the stream" do
    VideoStream.join(1, "tester")
    assert VideoStream.joined?(1, "tester")
  end

  test "leave leaves the stream" do
    VideoStream.join(1, "tester")
    VideoStream.leave(1, "tester")
    refute VideoStream.joined?(1, "tester")
  end

  test "user can only join the stream once" do
    VideoStream.join(1, "tester")
    VideoStream.join(1, "tester")
    assert VideoStream.subscribers(1) === 1
  end

  test "multiple users can join a stream" do
    VideoStream.join(1, "tester1")
    VideoStream.join(1, "tester2")
    assert VideoStream.subscribers(1) === 2
    assert VideoStream.joined?(1, "tester1")
    assert VideoStream.joined?(1, "tester2")
  end
end
