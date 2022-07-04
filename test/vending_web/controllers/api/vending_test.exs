defmodule VendingWeb.VendingTest do
  use VendingWeb.ConnCase, async: true

  alias Vending.Accounts
  import Vending.AccountsFixtures
  import Vending.ProductsFixtures

  setup :full_product_fixture

  describe "api/balance/deposit endpoint" do
    test "adds 20 to user account", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 20)
      assert %{"deposit" => 20} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 20
    end

    test "adds 100 to user account", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 100} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 100
    end

    test "accumulates successive calls", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 5)
      assert %{"deposit" => 205} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 205
    end

    test "rejects invalid values", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 60)
      assert response(conn, 422)

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 0
    end

    test "rejects float values", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 60.3)
      assert response(conn, 422)

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 0
    end

    test "rejects negative values", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: -60)
      assert response(conn, 422)

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 0
    end
  end

  describe "api/balance/reset endpoint" do

    test "resets user balance", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)

      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 100} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 100

      conn = post(conn, Routes.api_user_path(conn, :reset))
      assert %{"deposit" => 0} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :identify))
      assert json_response(conn, 200)["data"]["deposit"] == 0
    end

  end

  describe "api/balance endpoint" do

    test "returns correct balance", %{conn: conn, buyer: buyer} do
      conn = conn |> log_in_api_user(buyer)

      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :balance))
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]
    end

  end

  describe "api/purchase endpoint" do
    
    test "completes a purchase", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 2)
      assert %{"amount" => 2, "product_id" => product.id, "returns" => [0, 0, 0, 0, 1]} == json_response(conn, 200)["data"]
    end

    test "reduces product availability", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 2)
      assert %{"amount" => 2, "product_id" => product.id, "returns" => [0, 0, 0, 0, 1]} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_product_path(conn, :show, product.id))
      assert json_response(conn, 200)["data"]["amountAvailable"] == 40
    end

    test "completes a purchase - full balance", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 4)
      assert %{"amount" => 4, "product_id" => product.id, "returns" => [0, 0, 0, 0, 0]} == json_response(conn, 200)["data"]
    end

    test "fails - not enough deposit", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 6)
      assert response(conn, 422)
    end

    test "resets user balance", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      assert %{"deposit" => 200} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 2)
      assert %{"amount" => 2, "product_id" => product.id, "returns" => [0, 0, 0, 0, 1]} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_user_path(conn, :balance))
      assert %{"deposit" => 0} == json_response(conn, 200)["data"]
    end

    test "makes a correct return", %{conn: conn, buyer: buyer, product: product} do
      conn = conn |> log_in_api_user(buyer)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 100)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 50)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 20)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 20)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 20)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 10)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 10)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 5)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 5)
      conn = post(conn, Routes.api_user_path(conn, :deposit), amount: 5)

      assert %{"deposit" => 245} == json_response(conn, 200)["data"]

      conn = post(conn, Routes.api_vending_path(conn, :purchase), productId: product.id, amount: 2)
      # 245 - 100 = 145
      # 145 = 1 * 100 + 2 * 20 + 1 * 5
      assert %{"amount" => 2, "product_id" => product.id, "returns" => [1, 0, 2, 0, 1]} == json_response(conn, 200)["data"]
    end
  end

  defp create_product(_) do
    full_product_fixture()
  end

end
