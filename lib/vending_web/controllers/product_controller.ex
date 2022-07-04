defmodule VendingWeb.ProductController do
  use VendingWeb, :controller

  alias Vending.Products
  alias Vending.Products.Product

  plug :require_seller_web when action in [:new, :create, :edit, :update, :delete]
  plug :require_product_ownership_web when action in [:edit, :update, :delete]

  plug :require_buyer_web when action in [:purchase]

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, "index.html", products: products)
  end

  def new(conn, _params) do
    changeset = Products.change_product(%Product{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    user = Map.get(conn.assigns, :current_user, nil)
    product_params = Map.put(product_params, "sellerId", user.id)
    case Products.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, "show.html", product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    changeset = Products.change_product(product)
    render(conn, "edit.html", product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    case Products.update_product(product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end

  def purchase(conn, %{"productId" => product_id, "amount" => amount}) do
    current_user = Map.get(conn.assigns, :current_user)
    amount = String.to_integer(amount)
    product = Products.get_product!(product_id)

    case Vending.Purchases.make_purchase(current_user.id, product_id, amount) do
      {:ok, _purchase} ->
        conn
        |> put_flash(:info, "Product purchased successfully.")
        |> redirect(to: Routes.product_path(conn, :show, product))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Unable to make purchase.")
        |> redirect(to: Routes.product_path(conn, :show, product))
    end

    conn
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    {:ok, _product} = Products.delete_product(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: Routes.product_path(conn, :index))
  end
end
