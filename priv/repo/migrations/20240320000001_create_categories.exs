defmodule SmartMealPlan.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :external_id, :string
      add :source, :string, null: false, default: "kolichka"

      timestamps()
    end

    create unique_index(:categories, [:name, :source])
  end
end
