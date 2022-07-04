defmodule VendingWeb.Api.ProductView do
  use VendingWeb, :view
  alias VendingWeb.Api.ProductView

  def render("index.json", %{products: products}) do
    %{data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    %{
      id: product.id,
      amountAvailable: product.amountAvailable,
      cost: product.cost,
      productName: product.productName,
      sellerId: product.sellerId,
    }
  end
end
