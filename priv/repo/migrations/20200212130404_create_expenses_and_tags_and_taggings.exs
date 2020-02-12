defmodule Expenses.Repo.Migrations.CreateExpensesAndTagsAndTaggings do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :date, :date, null: false
      add :description, :text, null: false
      add :amount_eur_cents, :integer, null: false
      timestamps()
    end

    create index(:expenses, :user_id)

    create table(:tags) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :name, :text, null: false
      add :color, :text
      timestamps()
    end

    create index(:tags, :user_id)

    create table(:taggings) do
      add :expense_id, references(:expenses, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
      timestamps()
    end

    create index(:taggings, :expense_id)
    create index(:taggings, :tag_id)
  end
end
