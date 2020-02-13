defmodule ExpensesWeb.MainLive do
  use Phoenix.LiveView
  alias Expenses.Repo
  alias Expenses.Data
  alias Expenses.Data.Expense

  def render(assigns) do
    # Phoenix.View.render(
    ExpensesWeb.MainView.render("main.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    current_user = Data.get_user!(user_id)
    default_filters = %{"date_gte" => Date.today() |> Timex.beginning_of_year()}

    socket = assign(socket,
      current_user: current_user,
      filters: default_filters,
      new_expense_chg: new_expense_chg()
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
          |> assign(new_expense_chg: new_expense_chg(), newest_expense_id: expense.id)
          |> load_expenses()
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, new_expense_chg: changeset)
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

  defp new_expense_chg(), do: Data.expense_changeset(%Expense{}, %{})

  defp load_expenses(socket) do
    user = socket.assigns.current_user
    filters = Repo.prepare_filters(socket.assigns.filters, allowed: ~w(date_gte date_lte description_contains amount_lte amount_gte with_tags without_tags))

    expenses =
      Expense
      |> Expense.filter(user: user)
      |> Expense.filter(filters)
      |> Repo.all()

    assign(socket, expenses: expenses)
  end
end
