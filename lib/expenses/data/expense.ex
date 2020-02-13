defmodule Expenses.Data.Expense do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Expenses.Data

  schema "expenses" do
    belongs_to :user, Data.User
    has_many :taggings, Data.Tagging
    has_many :tags, through: [:taggings, :tag]

    field :date, :date
    field :description, :string
    field :amount_eur_cents, :integer
    timestamps()
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:user_id, :date, :description, :amount_eur_cents])
    |> validate_required([:user_id, :date, :description, :amount_eur_cents])
  end

  #
  # Filters
  #

  # e.g. Expense |> Expense.filter(date_gte: params["date"]) |> Repo.first()
  def filter(orig_query, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {key, val}, query -> f(query, key, val) end)
  end

  defp f(q, :id, id), do: where(q, [t], t.id == ^id)
  defp f(q, :date_gte, date), do: where(q, [t], t.date >= ^date)
  defp f(q, :date_lte, date), do: where(q, [t], t.date <= ^date)
end
