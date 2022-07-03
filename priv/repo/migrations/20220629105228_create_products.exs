defmodule Vending.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :amountAvailable, :integer
      add :cost, :integer
      add :productName, :string
      add :sellerId, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:products, [:sellerId])
  end
end
