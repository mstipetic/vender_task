defmodule Vending.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :amountAvailable, :integer
    field :cost, :integer
    field :productName, :string
    field :sellerId, :id

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:amountAvailable, :cost, :productName, :sellerId])
    |> validate_required([:amountAvailable, :cost, :productName])
    |> cost_greater_than_zero?
    |> valid_cost?
  end

  defp cost_greater_than_zero?(changeset) do
    price = get_change(changeset, :cost)
    if price == nil or price > 0 do
      changeset
    else
      add_error(changeset, :cost, "must be greater than 0")
    end
  end

  defp valid_cost?(changeset) do
    price = get_change(changeset, :cost)
    if price == nil or rem(price, 5) == 0 do
      changeset
    else
      add_error(changeset, :cost, "must be divisible by 5")
    end
  end
end
