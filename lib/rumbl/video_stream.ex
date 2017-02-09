defmodule Rumbl.VideoStream do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def join(video_id, user_id) do
    Agent.update(__MODULE__, fn map ->
      case Map.get(map, video_id, nil) do
        nil -> Map.put(map, video_id, MapSet.new([user_id]))
        users -> Map.update(map, video_id, users, fn users -> MapSet.put(users, user_id) end)
      end
    end)
  end

  def leave(video_id, user_id) do
    Agent.update(__MODULE__, fn map ->
      case Map.get(map, video_id, nil) do
        nil -> map
        users -> Map.update(map, video_id, users, fn users -> MapSet.delete(users, user_id) end)
      end

      # new_map = Map.update(map, video_id, 0, &(&1 - 1))
      # if (Map.get(new_map, video_id) == 0)  do
      #   Map.delete(new_map, video_id)
      # end
      # new_map
    end)
  end

  def joined?(video_id, user_id) do
    Agent.get(__MODULE__, fn map ->
      case Map.get(map, video_id, nil) do
        nil -> false
        users -> MapSet.member?(users, user_id)
      end
    end)
  end

  def subscribers(video_id) do
    Agent.get(__MODULE__, fn map ->
      MapSet.size(Map.get(map, video_id, MapSet.new))
    end)
  end
end
