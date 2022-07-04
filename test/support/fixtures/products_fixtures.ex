defmodule Vending.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Vending.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    seller = Vending.AccountsFixtures.user_seller_fixture()
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amountAvailable: 42,
        cost: 50,
        productName: "some productName",
        sellerId: seller.id
      })
      |> Vending.Products.create_product()

    %{product: product, user: seller}
  end

  def full_product_fixture(attrs \\ %{}) do
    seller = Vending.AccountsFixtures.user_seller_fixture()
    buyer = Vending.AccountsFixtures.user_fixture()
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amountAvailable: 42,
        cost: 50,
        productName: "some productName",
        sellerId: seller.id
      })
      |> Vending.Products.create_product()

    %{product: product, user: seller, buyer: buyer}
  end
end
