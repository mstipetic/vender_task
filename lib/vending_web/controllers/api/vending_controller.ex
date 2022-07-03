defmodule VendingWeb.Api.VendingController do
  use VendingWeb, :controller

  action_fallback VendingWeb.FallbackController

  plug :require_authenticated_user when action in [:purchase]
  plug :require_buyer when action in [:purchase]

  def purchase(conn, %{"productId" => product_id, "amount" => amount}) do
    user_id = Map.get(conn.assigns, :current_user)

    case Vending.Purchases.make_purchase(user_id, product_id, amount) do
      {:ok, purchase} ->
        conn
        |> render("purchase.json", purchase: purchase)
      {:error, reason} ->
        {:error, reason}
    end
  end
end

