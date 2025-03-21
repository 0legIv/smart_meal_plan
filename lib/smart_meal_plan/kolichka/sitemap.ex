defmodule SmartMealPlan.Kolichka.Sitemap do
  import SweetXml

  @sitemap_url "https://www.kolichka.bg/products_01.xml"

  def fetch_product_slugs do
    # Fetch the sitemap
    {:ok, %{body: body}} = Finch.build(:get, @sitemap_url) |> Finch.request(SmartMealPlanFinch)

    body
    |> SweetXml.xpath(~x"//url/loc/text()"sl)
    |> Enum.reduce([], fn url, acc -> do_fetch_slug(url, acc) end)
  end

  defp do_fetch_slug(url, acc) do
    regex = ~r/^https?:\/\/(?:www\.)?kolichka\.bg\/([^\/\?#]+)/

    case Regex.run(regex, url) do
      [_, slug] -> [slug | acc]
      _ -> acc
    end
  end
end
