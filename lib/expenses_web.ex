defmodule ExpensesWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ExpensesWeb, :controller
      use ExpensesWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ExpensesWeb

      import Plug.Conn
      import Phoenix.LiveView.Controller
      import ExpensesWeb.Gettext
      import ExpensesWeb.SentryPlugs
      alias ExpensesWeb.Router.Helpers, as: Routes

      # I'll make custom queries often enough that I might as well import these globally
      import Ecto.Query
      alias Expenses.Repo
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/expenses_web/templates",
        namespace: ExpensesWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Phoenix.LiveView.Helpers
      import ExpensesWeb.ErrorHelpers
      import ExpensesWeb.Gettext
      import ExpensesWeb.FormHelpers
      alias ExpensesWeb.Router.Helpers, as: Routes
      alias Expenses.Money
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ExpensesWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
