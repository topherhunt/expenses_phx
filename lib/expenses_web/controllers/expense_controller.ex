defmodule ExpensesWeb.ExpenseController do
  use ExpensesWeb, :controller

  plug :must_be_logged_in

  def index_live(conn, _params) do
    user = conn.assigns.current_user
    live_render(conn, ExpensesWeb.ExpenseIndexLive, session: %{"user_id" => user.id})
  end

  # def index_old(conn, params) do
  #   raw_filters = params["filters"] || default_filters()
  #   cleaned_filters = Repo.prepare_filters(raw_filters, allowed: ~w(date_gte date_lte description_contains amount_lte amount_gte with_tags without_tags))

  #   expenses =
  #     Expense
  #     |> Expense.filter(user: conn.assigns.current_user)
  #     |> Expense.filter(cleaned_filters)
  #     |> Repo.all()

  #   raise "TODO"
  # end

  #
  # Internal
  #

  # defp default_filters() do
  #   %{"date_gte" => Date.today() |> Timex.beginning_of_year()}
  # end
end
