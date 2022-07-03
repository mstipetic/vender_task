defmodule VendingWeb.UserSessionController do
  use VendingWeb, :controller

  alias Vending.Accounts
  alias VendingWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete_other(conn, _params) do
    IO.inspect(conn, label: :other)

    UserAuth.log_out_other_tokens(conn)
    
    conn
    |> put_flash(:info, "Other sessions have been logged out")
    |> redirect(to: Routes.product_path(conn, :index))

  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
