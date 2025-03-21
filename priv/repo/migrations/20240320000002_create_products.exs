defmodule SmartMealPlan.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :external_id, :string, null: false
      add :name, :string, null: false
      add :price, :decimal, null: false
      add :image_url, :string
      add :description_html, :text
      add :quantity_value, :decimal
      add :quantity_unit, :string
      add :price_per_unit, :decimal
      add :price_per_unit_unit, :string
      add :source, :string, null: false, default: "kolichka"
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:products, [:external_id, :source])
    create index(:products, [:category_id])
  end
end
