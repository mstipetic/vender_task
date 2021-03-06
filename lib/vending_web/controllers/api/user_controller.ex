defmodule VendingWeb.Api.UserController do
  use VendingWeb, :controller

  alias Vending.Accounts
  alias Vending.Accounts.User

  action_fallback VendingWeb.FallbackController

  plug :require_authenticated_user when action in [:index, :show, :delete, :identify, :balance, :deposit, :reset, :change_password]
  plug :only_on_self when action in [:show, :delete, :change_password]
  plug :require_buyer when action in [:balance, :deposit, :reset]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def identify(conn, _params) do
    id = Map.get(conn.assigns, :current_user)
    user = Accounts.get_user!(id)
    conn
    |> render("show.json", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    conn
    |> render("show.json", user: user)
  end

  def login(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    user = Accounts.get_user_by_email_and_password(email, password)
    token = Phoenix.Token.sign(VendingWeb.Endpoint, "token salt", user.id, max_age: 86400)
    bearer_token = "Bearer #{token}"

    conn
    |> put_status(:created)
    |> render("login.json", %{token: bearer_token})

  end

  def change_password(conn, %{"currentPassword" => current_password, "password" => _password} = password_data) do
    id = Map.get(conn.assigns, :current_user)
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user_password(user, current_password, password_data) do
      conn
      |> render("show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def balance(conn, _params) do
    id = Map.get(conn.assigns, :current_user)
    user = Accounts.get_user!(id)
    conn
    |> render("balance.json", %{user: user})
  end

  def deposit(conn, %{"amount" => amount}) when amount in [5, 10, 20, 50, 100] do
    id = Map.get(conn.assigns, :current_user)
    user = Accounts.get_user!(id)
    user = Accounts.add_user_balance(user, amount)
    conn
    |> render("balance.json", %{user: user})

  end

  def deposit(_conn, _params) do
    {:error, :invalid_amount}
  end

  def reset(conn, _params) do
    id = Map.get(conn.assigns, :current_user)
    user = Accounts.get_user!(id)
    user = Accounts.reset_user_balance(user)
    conn
    |> render("balance.json", %{user: user})
  end

end
