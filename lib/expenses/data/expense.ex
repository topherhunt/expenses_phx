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
    field :orig_amount, :float, virtual: true
    field :orig_amount_cents, :integer
    field :amount_eur_cents, :integer
    timestamps()
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:user_id, :date, :description, :orig_currency, :orig_amount, :orig_amount_cents, :amount_eur_cents])
    |> populate_orig_amount_cents()
    |> populate_amount_eur_cents()
    |> validate_required([:user_id, :date, :description, :orig_currency, :orig_amount_cents])
    |> validate_inclusion(:orig_currency, ["eur", "usd"])
  end

  defp populate_orig_amount_cents(changeset) do
    orig_amount = orig_amount = get_change(changeset, :orig_amount)
    if orig_amount do
      changeset |> put_change(:orig_amount_cents, round(orig_amount * 100))
    else
      changeset
    end
  end

  defp populate_amount_eur_cents(changeset) do
    orig_currency = get_field(changeset, :orig_currency)
    orig_amount_cents = get_field(changeset, :orig_amount_cents)
    amount_eur_is_missing = get_field(changeset, :amount_eur_cents) == nil

    if orig_currency && orig_amount_cents && amount_eur_is_missing do
      amount_eur_cents = case orig_currency do
        "eur" -> orig_amount_cents
        "usd" -> Money.usd_to_eur(orig_amount_cents)
      end

      changeset |> put_change(:amount_eur_cents, amount_eur_cents)
    else
      changeset
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
  defp f(q, :amount_gte, eur), do: where(q, [t], t.amount_eur_cents >= ^Money.to_cents(eur))
  defp f(q, :amount_lte, eur), do: where(q, [t], t.amount_eur_cents <= ^Money.to_cents(eur))
  defp f(q, :description_contains, s), do: where(q, [t], ilike(t.description, ^"%#{s}%"))
end
