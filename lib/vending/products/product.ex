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
  end
end
