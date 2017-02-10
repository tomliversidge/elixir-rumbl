defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel
  alias Rumbl.AnnotationView
  @commands ["wat", "help"]

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Repo.get!(Rumbl.Video, video_id)

    annotations = Repo.all(
      from a in assoc(video, :annotations),
      where: a.id > ^last_seen_id,
      order_by: [asc: a.at, asc: a.id],
      limit: 200,
      preload: [:user]
    )
    resp = %{annotations: Phoenix.View.render_many(annotations, AnnotationView, "annotation.json")}

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    changeset =
      user
      |> build_assoc(:annotations, video_id: socket.assigns.video_id)
      |> Rumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, annotation} ->
        broadcast_annotation(socket, annotation)
        check_for_commands(socket, annotation)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

defp check_for_commands(socket, annotation) do
  Enum.each(@commands, &(try_execute_command(&1, socket, annotation)))
end

defp try_execute_command(cmd, socket, annotation) do
  if String.contains?(annotation.body, cmd <> " ") do
    annotation = %{annotation | body: strip(annotation.body, cmd <> " ")}
    Task.start_link(fn -> compute_additional_info(annotation, socket) end)
  end
end

def strip(full, prefix) do
  base = byte_size(prefix)
  <<_::binary-size(base), rest::binary>> = full
  rest
end

  defp broadcast_annotation(socket, annotation) do
    annotation = Repo.preload(annotation, :user)
    render_annotation = Phoenix.View.render(AnnotationView, "annotation.json",
    %{
      annotation: annotation
      })
    broadcast! socket, "new_annotation", render_annotation
  end

  defp compute_additional_info(ann, socket) do
    for result <- Rumbl.InfoSys.compute(ann.body, limit: 1,
    timeout: 10_000) do
      attrs = %{url: result.url, body: result.text, at: ann.at}
      info_changeset =
        Rumbl.User
        |> Repo.get_by!(username: result.backend)
        |> build_assoc(:annotations, video_id: ann.video_id)
        |> Rumbl.Annotation.changeset(attrs)

        case Repo.insert(info_changeset) do
          {:ok, info_ann} -> broadcast_annotation(socket, info_ann)
          {:error, _changeset} -> :ignore
        end
    end
  end
end
