defmodule Expenses.Data.Expense do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Expenses.Data
  alias Expenses.Money

  schema "expenses" do
    belongs_to :user, Data.User
    has_many :taggings, Data.Tagging
    has_many :tags, through: [:taggings, :tag]

    field :date, :date
    field :description, :string
    field :orig_currency, :string
    field :orig_amount, :float
    field :amount_eur, :float
    timestamps()
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:user_id, :date, :description, :orig_currency, :orig_amount, :amount_eur])
    |> validate_required([:user_id, :date, :description, :orig_currency, :orig_amount])
    |> validate_inclusion(:orig_currency, ["eur", "usd"])
    |> populate_amount_eur()
  end

  defp populate_amount_eur(changeset) do
    already_set = get_field(changeset, :amount_eur) != nil
    invalid = length(changeset.errors) > 0

    if already_set || invalid do
      changeset
    else
      orig_currency = get_field(changeset, :orig_currency)
      orig_amount = get_field(changeset, :orig_amount)
      amount_eur = case orig_currency do
        "eur" -> orig_amount
        "usd" -> Money.usd_to_eur(orig_amount)
      end

      changeset |> put_change(:amount_eur, amount_eur)
    end
  end

  #
  # Filters
  #

  # e.g. Expense |> Expense.filter(date_gte: params["date"]) |> Repo.first()
  def filter(orig_query, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {key, val}, query -> f(query, key, val) end)
  end

  defp f(q, :id, id), do: where(q, [t], t.id == ^id)
  defp f(q, :user, user), do: where(q, [t], t.user_id == ^user.id)
  defp f(q, :date_gte, date), do: where(q, [t], t.date >= ^date)
  defp f(q, :date_lte, date), do: where(q, [t], t.date <= ^date)
end
