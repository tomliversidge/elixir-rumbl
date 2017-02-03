defmodule Rumbl.Repo.Migrations.DeletingCategoriesSetsForeignKeysToNull do
  use Ecto.Migration

  def change do

    execute "ALTER TABLE videos DROP CONSTRAINT videos_category_id_fkey"
    
    alter table(:videos) do
      modify :category_id, references(:categories, on_delete: :nilify_all)
    end
  end
end
