defmodule SmartMealPlan.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :external_id, :string
    field :source, :string, default: "kolichka"

    has_many :products, SmartMealPlan.Catalog.Product

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :external_id, :source])
    |> validate_required([:name, :source])
    |> unique_constraint([:name, :source])
  end
end
