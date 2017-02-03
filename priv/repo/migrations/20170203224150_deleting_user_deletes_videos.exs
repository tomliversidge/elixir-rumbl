defmodule Rumbl.Repo.Migrations.DeletingUserDeletesVideos do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE videos DROP CONSTRAINT videos_user_id_fkey"
    alter table(:videos) do
    modify :user_id, references(:users, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE videos DROP CONSTRAINT videos_user_id_fkey"
    alter table(:videos) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
  end
end
