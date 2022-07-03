defmodule VendingWeb.Router do
  use VendingWeb, :router

  import VendingWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {VendingWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_other_session_assigns
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug VendingWeb.Api.Auth
  end

  scope "/", VendingWeb do
    pipe_through :browser

  end

  # Other scopes may use custom stacks.
  scope "/api", VendingWeb.Api, as: :api do
    pipe_through :api

    resources "/products", ProductController

    get "/users", UserController, :index
    get "/users/me", UserController, :identify
    get "/users/:id", UserController, :show
    post "/users", UserController, :create
    delete "/users/:id", UserController, :delete

    post "/login", UserController, :login

    get "/balance", UserController, :balance
    post "/balance/deposit", UserController, :deposit
    post "/balance/reset", UserController, :reset

    post "/purchase", VendingController, :purchase
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VendingWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create


    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update

  end

  scope "/", VendingWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", ProductController, :index

    resources "/products", ProductController

    post "/purchase", ProductController, :purchase

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    get "/logout/all", UserSessionController, :delete_other
  end

  scope "/", VendingWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
