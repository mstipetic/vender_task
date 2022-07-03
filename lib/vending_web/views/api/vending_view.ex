defmodule VendingWeb.Api.VendingView do
  use VendingWeb, :view

  def render("purchase.json", %{purchase: purchase}) do
    %{data: purchase}
  end
end
