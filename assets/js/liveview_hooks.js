import $ from 'jquery'
import 'select2'

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

Hooks.NewExpenseForm = {
  mounted() {
    $('#new-expense-form').on('submit', function(){
      $('#new-expense-description').focus()
    })
  }
}

Hooks.FilterForm = {
  mounted() {
    let context = this
    $('#filter-form').on('change', function(e){
      // let data = $('#filter-form')
      //   .serializeArray()
      //   .reduce(function(acc, entry){ acc[entry.name] = entry.value; return acc }, {})
      // context.pushEvent("filter_expenses", data)
      // console.log("#filter-form change detected")
    })
  }
}

Hooks.Select2 = {
  mounted() {
    initSelect2(this.el)
  },
  // I could also wrap each select2 in <div phx-update="ignore"></div> to prevent updates
  updated() {
    initSelect2(this.el)
  }
}

function initSelect2(element) {
  $(element).select2({width: '100%'});
}

export default Hooks
