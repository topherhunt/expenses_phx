defmodule Expenses.Data do
  import Ecto.Query
  alias Expenses.Repo
  alias Expenses.Data.{User, Nonce, LoginTry, Expense, Tag, Tagging}

  #
  # Users
  #

  # New pattern: Each insert and update operation must provide a scope which is generally
  # :admin or :owner. :admin scope allows updates to all fields and should never be used
  # to pass user-defined params. :owner scope allows updates to only those fields which
  # should be updatable by the authed user who owns that record.
  def insert_user!(a \\ %User{}, b, c), do: insert_user(a, b, c) |> Repo.unwrap!()
  def insert_user(struct \\ %User{}, params, scope) do
    struct |> User.changeset(params, scope) |> Repo.insert()
  end

  def update_user!(%User{} = a, b, c), do: update_user(a, b, c) |> Repo.unwrap!()
  def update_user(%User{} = struct, params, scope) do
    struct |> User.changeset(params, scope) |> Repo.update()
  end

  def delete_user!(%User{} = user), do: Repo.delete!(user)

  def password_correct?(user_or_nil, password) do
    case Argon2.check_pass(user_or_nil, password) do
      {:ok, _user} -> true
      {:error, _msg} -> false
    end
  end

  #
  # Tokens
  #

  # Phoenix.Token gives us signed, salted, reversible, expirable tokens for free.
  # To protect from replay attacks, we embed a nonce id in each (otherwise stateless)
  # token. The nonce is validated at parsing time. Be sure to explicitly invalidate
  # the token when it's no longer needed!
  #
  # Usage:
  #   # Generate a single-use token:
  #   token = Data.new_token({:reset_password, user_id})
  #   # Later, parse and validate the token:
  #   {:ok, {:reset_password, user_id}} = Data.parse_token(token)
  #   # IMPORTANT: Destroy the token as soon as you no longer need it.
  #   Data.invalidate_token!(token)

  @endpoint ExpensesWeb.Endpoint
  @salt "XAnZSi88BVsMtchJVa9"
  @one_day 86400

  def create_token!(data) do
    nonce = insert_nonce!()
    wrapped_data = %{data: data, nonce_id: nonce.id}
    Phoenix.Token.sign(@endpoint, @salt, wrapped_data)
  end

  def parse_token(token) do
    case Phoenix.Token.verify(@endpoint, @salt, token, max_age: @one_day) do
      {:ok, map} ->
        case valid_nonce?(map.nonce_id) do
          true -> {:ok, map.data}
          false -> {:error, "invalid nonce"}
        end

      {:error, msg} -> {:error, msg}
    end
  end

  def invalidate_token!(token) do
    {:ok, map} = Phoenix.Token.verify(@endpoint, @salt, token, max_age: :infinity)
    delete_nonce!(map.nonce_id)
    :ok
  end

  #
  # Nonces
  #

  def insert_nonce! do
    Nonce.admin_changeset(%Nonce{}, %{}) |> Repo.insert!()
  end

  def valid_nonce?(id) do
    Repo.get(Nonce, id) != nil
  end

  def delete_nonce!(id) do
    Repo.get!(Nonce, id) |> Repo.delete!()
  end

  #
  # Login tries
  #

  def insert_login_try!(email) do
    LoginTry.admin_changeset(%LoginTry{}, %{email: email}) |> Repo.insert!()
  end

  def count_recent_login_tries(email) do
    start_time = Timex.now() |> Timex.shift(minutes: -15)
    LoginTry
    |> where([t], t.email == ^email and t.inserted_at >= ^start_time)
    |> Repo.count()
  end

  def clear_login_tries(email) do
    LoginTry
    |> where([t], t.email == ^email)
    |> Repo.delete_all()
  end

  #
  # Expenses
  #

  def insert_expense!(a \\ %Expense{}, b, c), do: insert_expense(a, b, c) |> Repo.unwrap!()
  def insert_expense(struct \\ %Expense{}, params, scope) do
    struct |> Expense.changeset(params, scope) |> Repo.insert()
  end

  def update_expense!(%Expense{} = a, b, c), do: update_expense(a, b, c) |> Repo.unwrap!()
  def update_expense(%Expense{} = struct, params, scope) do
    struct |> Expense.changeset(params, scope) |> Repo.update()
  end

  def delete_expense!(%Expense{} = expense), do: Repo.delete!(expense)

  #
  # Tags
  #

  def insert_tag!(a \\ %Tag{}, b, c), do: insert_tag(a, b, c) |> Repo.unwrap!()
  def insert_tag(struct \\ %Tag{}, params, scope) do
    struct |> Tag.changeset(params, scope) |> Repo.insert()
  end

  def update_tag!(%Tag{} = a, b, c), do: update_tag(a, b, c) |> Repo.unwrap!()
  def update_tag(%Tag{} = struct, params, scope) do
    struct |> Tag.changeset(params, scope) |> Repo.update()
  end

  def delete_tag!(%Tag{} = tag), do: Repo.delete!(tag)

  #
  # Taggings
  #

  def insert_tagging!(a \\ %Tagging{}, b, c), do: insert_tagging(a, b, c) |> Repo.unwrap!()
  def insert_tagging(struct \\ %Tagging{}, params, scope) do
    struct |> Tagging.changeset(params, scope) |> Repo.insert()
  end

  def update_tagging!(%Tagging{} = a, b, c), do: update_tagging(a, b, c) |> Repo.unwrap!()
  def update_tagging(%Tagging{} = struct, params, scope) do
    struct |> Tagging.changeset(params, scope) |> Repo.update()
  end

  def delete_tagging!(%Tagging{} = t), do: Repo.delete!(t)
end
