// See https://hexdocs.pm/phoenix_live_view/0.6.0/Phoenix.LiveView.html#module-js-interop-and-client-controlled-dom

let Hooks = {}

Hooks.ExpenseRow = {
  mounted() {
    // When an expense row is added to the table, if it's newly created, scroll to it.
    if (this.el.className.indexOf("expense-row--new") !== -1) {
      this.el.scrollIntoView()
    }
  }
}

Hooks.NewExpenseDescription = {
  updated() {
    this.el.focus()
  }
}

export default Hooks
