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

  def changeset(struct, params, :admin) do
    struct
    |> cast(params, [:user_id, :name, :color])
    |> validate_required([:user_id, :name, :color])
  end

  def changeset(struct, params, :owner) do
    struct
    |> cast(params, [:name, :color])
    |> changeset(%{}, :admin)
  end

  #
  # Query builders
  #

  def filter(orig_query \\ __MODULE__, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
  def filter(query, :user, user), do: where(query, [t], t.user_id == ^user.id)
  def filter(query, :order_by, :name), do: order_by(query, [t], asc: t.name)
  def filter(query, :preload, preloads), do: preload(query, ^preloads)
end
