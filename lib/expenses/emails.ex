defmodule Expenses.Emails do
  use Bamboo.Phoenix, view: ExpensesWeb.EmailsView
  import Bamboo.Email
  import ExpensesWeb.Gettext
  alias ExpensesWeb.Router.Helpers, as: Routes
  alias Expenses.Data
  alias Expenses.Data.User
  require Logger

  @endpoint ExpensesWeb.Endpoint

  def confirm_address(%User{} = user, email) do
    token = Data.create_token!({:confirm_email, user.id, email})
    url = Routes.auth_url(@endpoint, :confirm_email, token: token)

    if Mix.env == :dev, do: Logger.info "Email confirmation link sent to #{email}: #{url}"

    standard_email()
    |> to(email)
    |> subject("Worldview Journeys: #{gettext "Please confirm your address"}")
    |> render("confirm_address.html", url: url)
  end

  def reset_password(%User{} = user) do
    token = Data.create_token!({:reset_password, user.id})
    url = Routes.auth_url(@endpoint, :reset_password, token: token)

    if Mix.env == :dev, do: Logger.info "PW reset link sent to #{user.email}: #{url}"

    standard_email()
    |> to(user.email)
    |> subject("Worldview Journeys: #{gettext "Use this link to reset your password"}")
    |> render("reset_password.html", url: url)
  end

  #
  # Internal
  #

  defp standard_email do
    new_email()
    |> from({"Worldview Journeys", "noreply@worldviewjourneys.com"})
    |> put_html_layout({ExpensesWeb.LayoutView, "email.html"})
  end
end
