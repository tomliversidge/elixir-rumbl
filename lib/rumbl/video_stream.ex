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

  defp get_subscribers_for_video(mapset, video_id) do
    Enum.count(mapset, fn value ->
      case value do
        {^video_id, _} -> true
        {_, _} -> false
      end
    end)
  end
end
