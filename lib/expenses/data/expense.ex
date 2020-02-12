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

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
  def filter(query, :date_gte, date), do: where(query, [t], t.date >= ^date)
  def filter(query, :date_lte, date), do: where(query, [t], t.date <= ^date)
end
