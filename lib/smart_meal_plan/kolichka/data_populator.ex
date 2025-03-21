defmodule SmartMealPlan.Kolichka.DataPopulator do
  @moduledoc """
  Module responsible for populating the database with products and categories from kolichka.bg.
  This module can be used manually from IEx to control the data population process.
  """

  alias SmartMealPlan.Repo
  alias SmartMealPlan.Catalog.{Category, Product}
  alias SmartMealPlan.Kolichka.{Crawler, Sitemap}
  require Logger

  @doc """
  Starts the Finch HTTP client and populates the database with products and categories from kolichka.bg.
  Returns {:ok, stats} on success or {:error, reason} on failure.
  """
  def populate do
    Logger.info("Starting to populate products and categories from kolichka.bg")

    # Get all product slugs
    slugs = Sitemap.fetch_product_slugs()
    Logger.info("Found #{length(slugs)} products to process")

    # Process products and collect results
    {success, failure} =
      slugs
      |> Enum.reduce({0, 0}, fn slug, {success, failure} ->
        case process_product(slug) do
          {:ok, _} -> {success + 1, failure}
          {:error, _} -> {success, failure + 1}
        end
      end)

    # Calculate statistics
    stats = %{
      success: success,
      failure: failure
    }

    Logger.info("Population completed. Stats: #{inspect(stats)}")
    {:ok, stats}
  end

  @doc """
  Processes a single product and saves it to the database.
  Returns {:ok, product} on success or {:error, reason} on failure.
  """
  def process_product(slug) do
    case Crawler.fetch_product(slug) do
      {:ok, product_data} ->
        # First, ensure category exists
        category = ensure_category(product_data.category_name)

        # Prepare product attributes
        product_attrs = %{
          external_id: to_string(product_data.id),
          name: product_data.name,
          price: product_data.price,
          image_url: product_data.image,
          description_html: product_data.description_html,
          quantity_value: product_data.quantity_value,
          quantity_unit: product_data.quantity_unit,
          price_per_unit: product_data.price_per_unit,
          price_per_unit_unit: product_data.price_per_unit_unit,
          source: "kolichka",
          category_id: category.id
        }

        # Create or update product
        case Repo.get_by(Product, external_id: product_attrs.external_id, source: "kolichka") do
          nil ->
            case Repo.insert(%Product{} |> Product.changeset(product_attrs)) do
              {:ok, product} ->
                Logger.info("Inserted product: #{product.name} (ID: #{product.external_id})")
                {:ok, product}

              {:error, changeset} ->
                Logger.error(
                  "Failed to insert product #{product_data.name}: #{inspect(changeset.errors)}"
                )

                {:error, changeset}
            end

          existing_product ->
            case Repo.update(existing_product |> Product.changeset(product_attrs)) do
              {:ok, product} ->
                Logger.info("Updated product: #{product.name} (ID: #{product.external_id})")
                {:ok, product}

              {:error, changeset} ->
                Logger.error(
                  "Failed to update product #{product_data.name}: #{inspect(changeset.errors)}"
                )

                {:error, changeset}
            end
        end

      {:error, reason} ->
        Logger.error("Failed to fetch product #{slug}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Ensures a category exists in the database.
  Returns the category struct or nil if the category name is invalid.
  """
  def ensure_category(category_name) when is_binary(category_name) do
    case Repo.get_by(Category, name: category_name, source: "kolichka") do
      nil ->
        {:ok, category} =
          %Category{}
          |> Category.changeset(%{
            name: category_name,
            source: "kolichka"
          })
          |> Repo.insert()

        category

      existing_category ->
        existing_category
    end
  end

  def ensure_category(_), do: nil

  @doc """
  Cleans up all products and categories from kolichka.bg.
  """
  def cleanup do
    Logger.info("Cleaning up kolichka.bg data")
    Repo.delete_all(Product)
    Repo.delete_all(Category)
    Logger.info("Cleanup completed")
    :ok
  end
end
