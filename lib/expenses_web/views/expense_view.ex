defmodule ExpensesWeb.ExpenseView do
  use ExpensesWeb, :view

  # Old code for pretty tags dropdown:
  # <%= for tag <- @tags do %>
  #   <% selected = tag.name in (@filters["with_tags"] || []) %>
  #   <% selected_class = if selected, do: "tag--selected", else: "" %>
  #   <span class="tag <%= selected_class %>" style="background-color: <%= tag.color %>" phx-click=""><%= tag.name %></span>
  # <% end %>

  def primary_class(expense, currency) do
    if expense.orig_currency == currency do
      "currency--primary"
    else
      "currency--secondary"
    end
  end
end
