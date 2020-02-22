defmodule Expenses.Repo do
  use Ecto.Repo, otp_app: :expenses, adapter: Ecto.Adapters.Postgres
  import Ecto.Query

  def count(query), do: query |> select([t], count(t.id)) |> one()
  def any?(query), do: count(query) >= 1
  def first(query), do: query |> limit(1) |> one()
  def first!(query), do: query |> limit(1) |> one!()

  # Sanitizes and casts user-submitted filters against the field+type schema you provide.
  # Returns a kwlist that can be passed to a query builder function.
  # Usage:
  #   raw = %{"date_gte" => "2020-01-18"}
  #   filters = Repo.cast_filters(raw, [date_gte: :date, name: :string])
  #   => [date_gte: ~D[2020-01-18]]
  def cast_filters(raw_filters, fields_and_types) do
    Enum.reduce(fields_and_types, [], fn({field, type}, filters) ->
      if raw_value = Map.get(raw_filters, Atom.to_string(field)) do
        filters |> Keyword.put(field, cast_value(raw_value, type))
      else
        filters
      end
    end)
  end

  defp cast_value(raw_value, type) do
    case type do
      :string -> raw_value
      :date -> Date.from_iso8601!(raw_value)
      :currency -> Expenses.Money.to_cents(raw_value)
      {:array, :string} -> raw_value |> Enum.map(& &1) # verify it's an array
    end
  end

  # Assemble all this changeset's errors into a list of human-readable message.
  # e.g. ["username can't be blank", "password must be at most 20 characters"]
  def describe_errors(changeset) do
    if length(changeset.errors) == 0, do: raise "This changeset has no errors to describe!"

    changeset
    |> inject_vars_into_error_messages()
    |> Enum.map(fn({field, errors}) -> "#{field} #{Enum.join(errors, " and ")}" end)
    |> Enum.map(& String.replace(&1, "(s)", "s"))
  end

  defp inject_vars_into_error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn({msg, opts}) ->
      # e.g. input: {"must be at most %{count} chars", [count: 10, validation: ...]}
      #      output: "must be at most 3 chars"
      Enum.reduce(opts, msg, fn({key, value}, acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
