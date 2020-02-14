defmodule ExpensesWeb.ExpenseIndexLive do
  use Phoenix.LiveView
  import Ecto.Query
  alias Expenses.Repo
  alias Expenses.Data
  alias Expenses.Data.Expense

  def render(assigns) do
    # Phoenix.View.render(
    ExpensesWeb.ExpenseView.render("index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    current_user = Repo.get!(Data.User, user_id)
    tags = Ecto.assoc(current_user, :tags) |> order_by([t], t.name) |> Repo.all()
    default_filters = %{"date_gte" => Date.utc_today() |> Timex.beginning_of_year()}

    socket = assign(socket,
      current_user: current_user,
      filters: default_filters,
      tags: tags,
      new_changeset: new_changeset(%{"date" => Date.utc_today()}),
      newest_expense_id: nil
    )

    socket = load_expenses(socket)

    {:ok, socket}
  end

  #
  # Event handlers
  #

  def handle_event("create_expense", %{"expense" => expense_params}, socket) do
    expense_params = Map.put(expense_params, "user_id", socket.assigns.current_user.id)
    case Data.insert_expense(expense_params) do
      {:ok, expense} ->

        socket =
          socket
          |> assign(expenses: add_expense(socket.assigns.expenses, expense))
          |> assign(newest_expense_id: expense.id)
          |> assign(new_changeset: new_changeset(expense_params))
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, new_changeset: changeset, newest_expense_id: nil)
        {:noreply, socket}
    end
  end

  def handle_event("filter_expenses", %{"filters" => filter_params}, socket) do
    socket =
      socket
      |> assign(filters: filter_params)
      |> load_expenses()

    {:noreply, socket}
  end

  #
  # Internal
  #

  defp new_changeset(params) do
    params = Map.take(params, ["date", "orig_currency"])
    Data.expense_changeset(%Expense{}, params)
  end

  defp load_expenses(socket) do
    user = socket.assigns.current_user
    filters = Repo.prepare_filters(socket.assigns.filters, allowed: ~w(date_gte date_lte description_contains amount_lte amount_gte with_tags without_tags))

    expenses =
      Expense
      |> Expense.filter(user: user)
      |> Expense.filter(filters)
      |> order_by([e], [e.date, e.description])
      |> Repo.all()

    assign(socket, expenses: expenses)
  end

  defp add_expense(expenses, expense) do
    [expense | expenses] |> Enum.sort(& Date.compare(&1.date, &2.date) in [:lt, :eq])
  end
end
