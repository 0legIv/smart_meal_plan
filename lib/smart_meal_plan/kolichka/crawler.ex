defmodule SmartMealPlan.Kolichka.Crawler do
  alias SmartMealPlan.Kolichka.Sitemap
  require Logger

  @base_url "https://www.kolichka.bg/api/front/product/slug"

  def run do
    urls = Sitemap.fetch_product_slugs()

    urls
    |> Task.async_stream(&fetch_product/1, max_concurrency: 10, timeout: 30_000)
    |> Enum.to_list()
  end

  def fetch_product(slug) do
    url = "#{@base_url}/#{slug}?"

    case request(url) do
      {:ok, %{body: body, status: 200}} ->
        data = Jason.decode!(body)
        product = data["product"] || %{}

        name = product["name"]
        price = product["price"]
        image = product["image"]

        # Extract product description, if it exists
        description =
          product
          |> get_in(["detail", "description"])
          |> case do
            [first | _] -> Map.get(first, "value")
            _ -> nil
          end

        # Extract quantity info
        quantity_value = get_in(product, ["productQuantity", "value"])
        quantity_unit = get_in(product, ["productQuantity", "unit"])

        # Extract price per unit
        price_per_unit = get_in(product, ["pricePerUnit", "price"])
        price_per_unit_unit = get_in(product, ["pricePerUnit", "unit"])

        # Extract main category (name)
        category_name = get_in(product, ["mainCategory", "name"])

        product_data = %{
          id: product["id"],
          name: name,
          price: price,
          image: image,
          description_html: description,
          quantity_value: quantity_value,
          quantity_unit: quantity_unit,
          price_per_unit: price_per_unit,
          price_per_unit_unit: price_per_unit_unit,
          category_name: category_name
        }

        {:ok, product_data}

      {:ok, %{status: status}} ->
        {:error, "HTTP request failed with status #{status}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp request(url) do
    Finch.build(:get, url)
    |> Finch.request(SmartMealPlanFinch)
  end
end
