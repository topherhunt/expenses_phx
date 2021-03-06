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
    default_filters = %{"date_gte" => "#{beginning_of_year()}"}

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
    user = socket.assigns.current_user

    case Data.insert_expense(%Expense{user_id: user.id}, expense_params, :owner) do
      {:ok, expense} ->
        my_tag_ids = Ecto.assoc(user, :tags) |> Repo.all() |> Enum.map(& &1.id)
        expense_params["tag_ids"]
        |> Enum.map(& String.to_integer(&1))
        |> Enum.filter(& &1 in my_tag_ids)
        |> Enum.each(& Data.insert_tagging!(%{expense_id: expense.id, tag_id: &1}, :owner))

        socket =
          socket
          |> load_expenses()
          |> assign(newest_expense_id: expense.id)
          |> assign(new_changeset: new_changeset(expense_params))
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, new_changeset: changeset, newest_expense_id: nil)
        {:noreply, socket}
    end
  end

  def handle_event("filter_expenses", %{"filters" => filter_params}, socket) do
    IO.inspect(filter_params, label: "filter_expenses called with filters")
    socket =
      socket
      |> assign(filters: filter_params)
      |> load_expenses()

    {:noreply, socket}
  end

  #
  # Internal
  #

  defp beginning_of_year, do: Date.utc_today() |> Timex.beginning_of_year()

  defp new_changeset(params) do
    params = Map.take(params, ["date", "orig_currency"])
    Expense.changeset(%Expense{}, params, :owner)
  end

  defp load_expenses(socket) do
    user = socket.assigns.current_user

    filters = Repo.cast_filters(socket.assigns.filters, [
      date_gte: :date,
      date_lte: :date,
      description: :string,
      amount_lte: :currency,
      amount_gte: :currency,
      has_all_tag_ids: {:array, :integer},
      has_any_tag_id: {:array, :integer},
      has_no_tag_id: {:array, :integer}
    ])

    expenses =
      Expense
      |> Expense.filter(user: user)
      |> Expense.filter(filters)
      |> preload([t], :tags)
      |> order_by([e], [e.date, e.description])
      # |> Repo.debug()
      |> Repo.all()

    assign(socket, expenses: expenses)
  end

  # defp add_expense(expenses, expense) do
  #   [expense | expenses] |> Enum.sort(& Date.compare(&1.date, &2.date) in [:lt, :eq])
  # end
end
