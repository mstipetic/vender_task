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

{:ok, seller_1} = Vending.Accounts.register_user(%{email: "hello2@email.com", password: "Password123!", role: "seller"})
{:ok, buyer_1} = Vending.Accounts.register_user(%{email: "hello@email.com", password: "Password123!", role: "buyer"})

Vending.Products.create_product(%{
  amountAvailable: 300,
  cost: 50,
  productName: "Product 1",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 300,
  cost: 50,
  productName: "Product 2",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 300,
  cost: 50,
  productName: "Product 3",
  sellerId: seller_1.id,
})

Vending.Products.create_product(%{
  amountAvailable: 100,
  cost: 50,
  productName: "Product 4",
  sellerId: seller_1.id,
})
