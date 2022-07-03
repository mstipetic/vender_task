defmodule Vending.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vending.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amountAvailable: 42,
        cost: 42,
        productName: "some productName"
      })
      |> Vending.Products.create_product()

    product
  end
end
