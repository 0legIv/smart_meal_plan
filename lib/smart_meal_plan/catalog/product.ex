defmodule SmartMealPlan.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :external_id, :string
    field :name, :string
    field :price, :decimal
    field :image_url, :string
    field :description_html, :string
    field :quantity_value, :decimal
    field :quantity_unit, :string
    field :price_per_unit, :decimal
    field :price_per_unit_unit, :string
    field :source, :string, default: "kolichka"
    belongs_to :category, SmartMealPlan.Catalog.Category

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :external_id,
      :name,
      :price,
      :image_url,
      :description_html,
      :quantity_value,
      :quantity_unit,
      :price_per_unit,
      :price_per_unit_unit,
      :source,
      :category_id
    ])
    |> validate_required([:external_id, :name, :price, :source])
    |> unique_constraint([:external_id, :source])
    |> foreign_key_constraint(:category_id)
  end
end
