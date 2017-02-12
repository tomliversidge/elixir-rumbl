defmodule Rumbl.Channels.VideoChannelTest do
  use Rumbl.ChannelCase
  import Rumbl.TestHelpers

  setup do
    user = insert_user(name: "Rebecca")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(Rumbl.UserSocket, %{"token" => token})
    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, video: vid} do
    for body <- ~w(one, two) do
      vid
      |> build_assoc(:annotations, %{body: body})
      |> Repo.insert!()
    end
    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})

    assert socket.assigns.video_id == vid.id
    annotations = Map.get(reply, :annotations)
    first_annotation = Enum.at(annotations, 0)
    assert first_annotation = %{body: "one"}
    second_annotation = Enum.at(annotations, 1)
    assert second_annotation = %{body: "two"}
  end
end
