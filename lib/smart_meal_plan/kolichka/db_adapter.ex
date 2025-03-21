defmodule SmartMealPlan.Kolichka.DbAdapter do
  @moduledoc """
  Database adapter for managing products from Kolichka crawler.
  """

  alias SmartMealPlan.Catalog.Product
  alias SmartMealPlan.Repo
  import Ecto.Query

  @doc """
  Saves a list of products to the database.
  Products that already exist (by name) will be updated.
  """
  def save_products(products) when is_list(products) do
    Enum.map(products, &upsert_product/1)
  end

  @doc """
  Saves a single product to the database.
  If the product already exists (by name), it will be updated.
  """
  def upsert_product(product_attrs) when is_map(product_attrs) do
    case Repo.get_by(Product, name: product_attrs.name) do
      nil -> %Product{}
      existing_product -> existing_product
    end
    |> Product.changeset(product_attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Retrieves all products from the database.
  """
  def get_all_products do
    Repo.all(Product)
  end

  @doc """
  Retrieves products by category name.
  """
  def get_products_by_category(category_name) do
    Product
    |> where([p], p.category_name == ^category_name)
    |> Repo.all()
  end

  @doc """
  Retrieves a product by its name.
  """
  def get_product_by_name(name) do
    Repo.get_by(Product, name: name)
  end

  @doc """
  Retrieves products with prices within the specified range.
  """
  def get_products_by_price_range(min_price, max_price) do
    Product
    |> where([p], p.price >= ^min_price and p.price <= ^max_price)
    |> Repo.all()
  end
end
