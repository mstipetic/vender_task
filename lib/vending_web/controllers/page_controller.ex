defmodule VendingWeb.PageController do
  use VendingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
