defmodule VendingWeb.Api.ProductController do
  use VendingWeb, :controller

  alias Vending.Products
  alias Vending.Products.Product

  action_fallback VendingWeb.FallbackController

  plug :require_authenticated_user when action in [:index, :show, :create, :delete]

  plug :require_seller when action in [:create, :update, :delete]
  plug :only_on_own_product when action in [:update, :delete]

  def index(conn, _params) do
    products = Products.list_products()
    render(conn, "index.json", products: products)
  end

  def create(conn, %{"product" => product_params}) do
    user_id = Map.get(conn.assigns, :current_user, nil)
    product_params = Map.put(product_params, "sellerId", user_id)
    with {:ok, %Product{} = product} <- Products.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.api_product_path(conn, :show, product))
      |> render("show.json", product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Products.get_product!(id)
    render(conn, "show.json", product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Products.get_product!(id)

    with {:ok, %Product{} = product} <- Products.update_product(product, product_params) do
      render(conn, "show.json", product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Products.get_product!(id)

    with {:ok, %Product{}} <- Products.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
