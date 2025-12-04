defmodule GoGame.Repo.Migrations.AddLocationAndAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :location_city, :string
      add :is_admin, :boolean, default: false, null: false
    end

    create index(:users, [:is_admin])
  end
end
