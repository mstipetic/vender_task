# Vender

Vender is a demo app built in Elixir/Phoenix for demo purposes.

To start your Vender app:

  * Start a postgres instance `docker run --name psql -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=vending_dev -p 5432:5432 --rm postgres`
  * Install dependencies with `mix deps.get`
  * Create and migrate and populate your database with `mix setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Architecture

The system uses a standard MVC pattern, with separate Views and Controllers for access through the browser and through an API.
When accessing through the browser, we're using the standard HTTP methods and HTML forms to interact with the backend.
Another way of accessing is through the JSON api (routes beginning with `/api`).

## API routes

```
api_product_path          GET                /api/products                         VendingWeb.Api.ProductController        :index
api_product_path          GET                /api/products/:id/edit                VendingWeb.Api.ProductController        :edit
api_product_path          GET                /api/products/new                     VendingWeb.Api.ProductController        :new
api_product_path          GET                /api/products/:id                     VendingWeb.Api.ProductController        :show
api_product_path          POST               /api/products                         VendingWeb.Api.ProductController        :create
api_product_path          PATCH              /api/products/:id                     VendingWeb.Api.ProductController        :update
PUT                       /api/products/:id  VendingWeb.Api.ProductController      :update
api_product_path          DELETE             /api/products/:id                     VendingWeb.Api.ProductController        :delete
api_user_path             GET                /api/users                            VendingWeb.Api.UserController           :index
api_user_path             GET                /api/users/me                         VendingWeb.Api.UserController           :identify
api_user_path             GET                /api/users/:id                        VendingWeb.Api.UserController           :show
api_user_path             POST               /api/users                            VendingWeb.Api.UserController           :create
api_user_path             POST               /api/users/:id/change_password        VendingWeb.Api.UserController           :change_password
api_user_path             DELETE             /api/users/:id                        VendingWeb.Api.UserController           :delete
api_user_path             POST               /api/login                            VendingWeb.Api.UserController           :login
api_user_path             GET                /api/balance                          VendingWeb.Api.UserController           :balance
api_user_path             POST               /api/balance/deposit                  VendingWeb.Api.UserController           :deposit
api_user_path             POST               /api/balance/reset                    VendingWeb.Api.UserController           :reset
api_vending_path          POST               /api/purchase                         VendingWeb.Api.VendingController        :purchase
*                         /dev/mailbox       Plug.Swoosh.MailboxPreview            []
user_registration_path    GET                /users/register                       VendingWeb.UserRegistrationController   :new
user_registration_path    POST               /users/register                       VendingWeb.UserRegistrationController   :create
user_session_path         GET                /users/log_in                         VendingWeb.UserSessionController        :new
user_session_path         POST               /users/log_in                         VendingWeb.UserSessionController        :create
user_reset_password_path  GET                /users/reset_password                 VendingWeb.UserResetPasswordController  :new
user_reset_password_path  POST               /users/reset_password                 VendingWeb.UserResetPasswordController  :create
user_reset_password_path  GET                /users/reset_password/:token          VendingWeb.UserResetPasswordController  :edit
user_reset_password_path  PUT                /users/reset_password/:token          VendingWeb.UserResetPasswordController  :update
product_path              GET                /                                     VendingWeb.ProductController            :index
product_path              GET                /products                             VendingWeb.ProductController            :index
product_path              GET                /products/:id/edit                    VendingWeb.ProductController            :edit
product_path              GET                /products/new                         VendingWeb.ProductController            :new
product_path              GET                /products/:id                         VendingWeb.ProductController            :show
product_path              POST               /products                             VendingWeb.ProductController            :create
product_path              PATCH              /products/:id                         VendingWeb.ProductController            :update
PUT                       /products/:id      VendingWeb.ProductController          :update
product_path              DELETE             /products/:id                         VendingWeb.ProductController            :delete
product_path              POST               /purchase                             VendingWeb.ProductController            :purchase
user_settings_path        POST               /deposit                              VendingWeb.UserSettingsController       :deposit
user_settings_path        GET                /users/settings                       VendingWeb.UserSettingsController       :edit
user_settings_path        PUT                /users/settings                       VendingWeb.UserSettingsController       :update
user_settings_path        GET                /users/settings/confirm_email/:token  VendingWeb.UserSettingsController       :confirm_email
user_session_path         GET                /logout/all                           VendingWeb.UserSessionController        :delete_other
user_session_path         DELETE             /users/log_out                        VendingWeb.UserSessionController        :delete
user_confirmation_path    GET                /users/confirm                        VendingWeb.UserConfirmationController   :new
user_confirmation_path    POST               /users/confirm                        VendingWeb.UserConfirmationController   :create
user_confirmation_path    GET                /users/confirm/:token                 VendingWeb.UserConfirmationController   :edit
user_confirmation_path    POST               /users/confirm/:token                 VendingWeb.UserConfirmationController   :update


```

## Authentication

When logging in through the browser a standard session cookie is set and persisted in a database.
Upon each request this cookie value is validated and an user is assigned to this request-response cycle.
Users can log other sessions out, by triggering an endpoing which deletes other session tokens tied to that user.

When logging through an API a JWT Bearer token is generated which encodes the `user.id`.

## Possible improvements

* Better feedback on faulty imputs - currently the request fails in an opaque way, better feedback should be provided
* Better feedback on business logic fails - currently the request fails in an opaque way, better feedback should be provided
* Use of DB transactions - due to time constraints some important operations (purchases, for example) which touch multiple DB entities do not use DB transactions
* Better logging

