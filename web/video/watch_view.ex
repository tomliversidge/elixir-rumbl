defmodule Rumbl.WatchView do
  use Rumbl.Web, {:view, %{root: "web/video/watch", path: ""}}

  def player_id(video) do
    ~r{^.*(?:youtu\.be/|\w+/|v=)(?<id>[^#&?]*)}
    |> Regex.named_captures(video.url)
    |> get_in(["id"])
  end
end
