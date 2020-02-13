defmodule ExpensesWeb.MainController do
  use ExpensesWeb, :controller

  def main(conn, _params) do
    live_render(conn, Expenses.MainLive)
  end
end
