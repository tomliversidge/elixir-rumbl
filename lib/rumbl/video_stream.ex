defmodule Rumbl.VideoStream do
  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def join(video_id, user) do
    Agent.update(__MODULE__, fn mapset ->
      MapSet.put(mapset, {video_id, user})
    end)
  end

  def leave(video_id, user) do
    Agent.update(__MODULE__, fn mapset ->
      MapSet.delete(mapset, {video_id, user})
    end)
  end

  def joined?(video_id, user) do
    Agent.get(__MODULE__, fn mapset ->
      MapSet.member?(mapset, {video_id, user})
    end)
  end

  def subscribers(video_id) do
    Agent.get(__MODULE__, &(get_subscribers_for_video(&1, video_id)))
  end

  defp filter_by_video_id({vid, _}, video_id), do: vid === video_id

  defp map_user({_, user}), do: user

  defp get_subscribers_for_video(mapset, video_id) do
    mapset
    |> Enum.filter_map(
      &(filter_by_video_id(&1, video_id)),
      &map_user/1
      )
  end

  def reset do
    Agent.update(__MODULE__, fn _ ->
      MapSet.new
    end)
  end
end
