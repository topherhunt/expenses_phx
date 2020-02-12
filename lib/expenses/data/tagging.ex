defmodule Expenses.Data.Tagging do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Expenses.Data

  schema "taggings" do
    belongs_to :expense, Data.Expense
    belongs_to :tag, Data.Tag
    timestamps()
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:expense_id, :tag_id])
    |> validate_required([:expense_id, :tag_id])
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
  def filter(query, :tag, tag), do: where(query, [t], t.tag_id == ^tag.id)
  def filter(query, :expense, exp), do: where(query, [t], t.expense_id == ^exp.id)
end
