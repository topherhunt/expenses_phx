defmodule Expenses.Data.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Expenses.Data

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :last_visit_date, :date
    timestamps()

    has_many :tags, Data.Tag
  end

  def changeset(struct, params, :admin) do
    struct
    |> cast(params, [:name, :email, :password, :confirmed_at, :last_visit_date])
    |> validate_required([:name, :email])
    |> validate_length(:password, min: 8, max: 50)
    |> unique_constraint(:email)
    |> require_password()
    |> hash_password_if_present()
  end

  def changeset(struct, params, :owner) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation, :current_password])
    |> disallow_email_change()
    |> validate_password_confirmation()
    |> validate_current_password()
    |> changeset(%{}, :admin) # hash password, require fields, etc.
  end

  # We need a special context for pw resets because current_password isn't required there
  def changeset(%__MODULE__{} = struct, params, :password_reset) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_password_confirmation()
    |> changeset(%{}, :admin) # hash password, require fields, etc.
  end

  #
  # Validation helpers
  #

  defp hash_password_if_present(changeset) do
    if password = get_change(changeset, :password) do
      hashed = Argon2.hash_pwd_salt(password)
      changeset |> change(%{password: nil, password_hash: hashed})
    else
      changeset
    end
  end

  defp require_password(changeset) do
    if !get_field(changeset, :password_hash) && !get_change(changeset, :password) do
      add_error(changeset, :password, "can't be blank")
    else
      changeset
    end
  end

  defp disallow_email_change(changeset) do
    # Users can't directly change their email address after registering. UserController#update has logic for updating email via confirmation link.
    if get_field(changeset, :id) && get_change(changeset, :email) do
      add_error(changeset, :email, "can't be updated without a confirmation email")
    else
      changeset
    end
  end

  defp validate_password_confirmation(changeset) do
    password = get_change(changeset, :password)
    password_confirmation = get_change(changeset, :password_confirmation)

    if password != nil && password != password_confirmation do
      add_error(changeset, :password_confirmation, "doesn't match password")
    else
      changeset
    end
  end

  defp validate_current_password(changeset) do
    user = changeset.data
    is_user_persisted = user.id != nil
    is_changing_password = get_change(changeset, :password) != nil

    if is_user_persisted && is_changing_password do
      current_password = get_change(changeset, :current_password)
      current_password_correct = Data.password_correct?(user, current_password)
      if !current_password_correct do
        add_error(changeset, :current_password, "is incorrect")
      else
        changeset
      end
    else
      changeset
    end
  end

  #
  # Filters
  #

  def filter(orig_query \\ __MODULE__, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
  def filter(query, :email, email), do: where(query, [t], t.email == ^email)
end
