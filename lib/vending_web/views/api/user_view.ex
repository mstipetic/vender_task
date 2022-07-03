defmodule VendingWeb.Api.UserView do
  use VendingWeb, :view
  alias VendingWeb.Api.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("login.json", %{token: token}) do
    %{data: %{token: token}}
  end

  def render("balance.json", %{user: user}) do
    %{data: %{balance: user.deposit}}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      deposit: user.deposit,
      role: user.role,
    }
  end

end
