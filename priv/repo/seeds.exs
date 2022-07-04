# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vending.Repo.insert!(%Vending.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Vending.Accounts.User
alias Vending.Products.Product

{:ok, seller_1} = Vending.Accounts.register_user(%{email: "seller1@email.com", password: "Password123!", role: "seller"})
{:ok, seller_2} = Vending.Accounts.register_user(%{email: "seller2@email.com", password: "Password123!", role: "seller"})
{:ok, buyer_1} = Vending.Accounts.register_user(%{email: "buyer1@email.com", password: "Password123!", role: "buyer"})
{:ok, buyer_2} = Vending.Accounts.register_user(%{email: "buyer2@email.com", password: "Password123!", role: "buyer"})

Vending.Products.create_product(%{
  amountAvailable: 12,
  cost: 50,
  productName: "Product 1",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 5,
  cost: 10,
  productName: "Product 2",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 1,
  cost: 5,
  productName: "Product 3",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 5,
  cost: 20,
  productName: "Product 4",
  sellerId: seller_2.id,
})

Vending.Products.create_product(%{
  amountAvailable: 4,
  cost: 25,
  productName: "Product 5",
  sellerId: seller_2.id,
})

Vending.Products.create_product(%{
  amountAvailable: 10,
  cost: 50,
  productName: "Product 6",
  sellerId: seller_2.id,
})
