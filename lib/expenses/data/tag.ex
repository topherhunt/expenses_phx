defmodule Expenses.Data.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Expenses.Data

  schema "tags" do
    belongs_to :user, Data.User
    has_many :taggings, Data.Tagging
    has_many :expenses, through: [:taggings, :expense]

    field :name, :string
    field :color, :string
    timestamps()
  end

  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:user_id, :name, :color])
    |> validate_required([:user_id, :name, :color])
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
end
