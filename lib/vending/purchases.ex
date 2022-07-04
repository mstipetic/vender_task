defmodule Vending.Purchases do
  alias Vending.Accounts
  alias Vending.Products
  alias Vending.Accounts.User
  alias Vending.Products.Product

  import Ecto.Query, warn: false
  alias Vending.Repo

  def make_purchase(user_id, product_id, amount) do
    user = Accounts.get_user!(user_id)
    product = Products.get_product!(product_id)
    total_price = product.cost * amount
    if (user.deposit >= total_price) and (product.amountAvailable >= amount) do
      from(u in User, where: u.id == ^user.id, update: [set: [deposit: u.deposit - ^total_price]]) |> Repo.update_all([])
      from(p in Product, where: p.id == ^product_id, update: [set: [amountAvailable: p.amountAvailable - ^amount]]) |> Repo.update_all([])
      Accounts.reset_user_balance(user)
      returns = Vending.Utils.calculate_return(user.deposit - total_price)
      {:ok, %{amount: amount, product_id: product.id, returns: returns}}
    else
      {:error, :not_possible}
    end

  end

end
