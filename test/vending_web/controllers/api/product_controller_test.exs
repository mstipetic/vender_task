defmodule VendingWeb.Api.ProductControllerTest do
  use VendingWeb.ConnCase

  import Vending.ProductsFixtures

  alias Vending.Products.Product

  @create_attrs %{
    amountAvailable: 42,
    cost: 50,
    productName: "some productName"
  }
  @update_attrs %{
    amountAvailable: 43,
    cost: 60,
    productName: "some updated productName"
  }
  @invalid_attrs %{amountAvailable: nil, cost: nil, productName: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_product]
    test "lists all products", %{conn: conn, user: user} do
      conn = conn |> log_in_api_user(user)
      conn = get(conn, Routes.api_product_path(conn, :index))
      assert length(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "create product" do
    setup [:create_product]
    test "renders product when data is valid", %{conn: conn, user: user} do
      conn = conn |> log_in_api_user(user)
      conn = post(conn, Routes.api_product_path(conn, :create), product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_product_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "amountAvailable" => 42,
               "cost" => 50,
               "productName" => "some productName"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn |> log_in_api_user(user)
      conn = post(conn, Routes.api_product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, user: user, product: %Product{id: id} = product} do
      conn = conn |> log_in_api_user(user)
      conn = put(conn, Routes.api_product_path(conn, :update, product), product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_product_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "amountAvailable" => 43,
               "cost" => 60,
               "productName" => "some updated productName"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, product: product} do
      conn = conn |> log_in_api_user(user)
      conn = put(conn, Routes.api_product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, user: user, product: product} do
      conn = conn |> log_in_api_user(user)
      conn = delete(conn, Routes.api_product_path(conn, :delete, product))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_product_path(conn, :show, product))
      end
    end
  end

  defp create_product(_) do
    product_fixture()
  end
end
