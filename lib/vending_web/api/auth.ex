defmodule VendingWeb.Api.Auth do

  import Plug.Conn
  import Phoenix.Controller

  import Ecto.Query, warn: false
  alias Vending.Repo

  alias Vending.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    token = get_token(conn)
    case verify_token(token) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        conn
        |> assign(:current_user, user_id)
        |> assign(:current_role, user.role)
      _unauthorized ->
        conn
        |> assign(:current_user, nil)
        |> assign(:current_role, nil)
    end
  end

  def require_authenticated_user(conn, _opts) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(VendingWeb.ErrorView)
      |> render(:"401")
      # Stop any downstream transformations.
      |> halt()
    end
  end

  def only_on_self(conn, _opts) do
    {param_user_id, _} = Integer.parse(Map.get(conn.params, "id"))
    current_user_id = Map.get(conn.assigns, :current_user)
    if param_user_id == current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(VendingWeb.ErrorView)
      |> render(:"401")
      # Stop any downstream transformations.
      |> halt()
    end
  end

  def only_on_own_product(conn, _opts) do
    {param_product_id, _} = Integer.parse(Map.get(conn.params, "id"))
    current_user_id = Map.get(conn.assigns, :current_user)

    IO.puts("#{current_user_id} tried #{param_product_id}")

    product = Vending.Products.get_product!(param_product_id)
    if product.sellerId == current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(VendingWeb.ErrorView)
      |> render(:"401")
      # Stop any downstream transformations.
      |> halt()
    end
  end

  def require_buyer(conn, _opts) do
    current_user_role = Map.get(conn.assigns, :current_role)
    if current_user_role == :buyer do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(VendingWeb.ErrorView)
      |> render(:"401")
      # Stop any downstream transformations.
      |> halt()
    end
  end

  def require_seller(conn, _opts) do
    current_user_role = Map.get(conn.assigns, :current_role)
    IO.puts("current user role #{current_user_role}")
    if current_user_role == :seller do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(VendingWeb.ErrorView)
      |> render(:"401")
      # Stop any downstream transformations.
      |> halt()
    end
  end

  @spec verify_token(nil | binary) :: {:error, :expired | :invalid | :missing} | {:ok, any}
  def verify_token(token) do
    one_month = 30 * 24 * 60 * 60

    Phoenix.Token.verify(
      VendingWeb.Endpoint,
      "token salt",
      token,
      max_age: one_month
    )
  end

  @spec get_token(Plug.Conn.t()) :: nil | binary
  def get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

end
