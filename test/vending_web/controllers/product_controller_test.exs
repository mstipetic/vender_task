defmodule VendingWeb.ProductControllerTest do
  use VendingWeb.ConnCase

  import Vending.ProductsFixtures
  import Vending.AccountsFixtures

  @create_attrs %{amountAvailable: 42, cost: 40, productName: "some productName"}
  @update_attrs %{amountAvailable: 43, cost: 40, productName: "some updated productName"}
  @invalid_attrs %{amountAvailable: nil, cost: nil, productName: nil}

  describe "index" do
    setup :register_and_log_in_seller_user
    test "lists all products", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Products"
    end
  end

  describe "new product" do
    setup :register_and_log_in_seller_user
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.product_path(conn, :new))
      assert html_response(conn, 200) =~ "New Product"
    end
  end

  describe "create product" do
    setup :register_and_log_in_seller_user
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      assign(conn, :current_user, user)
      conn = post(conn, Routes.product_path(conn, :create), product: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.product_path(conn, :show, id)

      conn = get(conn, Routes.product_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Product"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      assign(conn, :current_user, user)
      conn = post(conn, Routes.product_path(conn, :create), product: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Product"
    end
  end

  describe "edit product" do
    setup [:create_product]

    test "renders form for editing chosen product", %{conn: conn, user: user, product: product} do
      conn = conn |> log_in_user(user)
      conn = get(conn, Routes.product_path(conn, :edit, product))
      assert html_response(conn, 200) =~ "Edit Product"
    end
  end

  describe "update product" do
    setup [:create_product]

    test "redirects when data is valid", %{conn: conn, user: user, product: product} do
      conn = conn |> log_in_user(user)
      conn = put(conn, Routes.product_path(conn, :update, product), product: @update_attrs)
      assert redirected_to(conn) == Routes.product_path(conn, :show, product)

      conn = get(conn, Routes.product_path(conn, :show, product))
      assert html_response(conn, 200) =~ "some updated productName"
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, user: user, product: product} do
      conn = conn |> log_in_user(user)
      conn = delete(conn, Routes.product_path(conn, :delete, product))
      assert redirected_to(conn) == Routes.product_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.product_path(conn, :show, product))
      end
    end
  end

  defp create_product(_) do
    product_fixture()
  end
end
