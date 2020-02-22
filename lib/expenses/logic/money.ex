defmodule Expenses.Money do
  def eur_to_usd(cents) when is_integer(cents) do
    (cents * 1.1) |> round()
  end

  def usd_to_eur(cents) when is_integer(cents) do
    (cents * 1.0 / 1.1) |> round()
  end

  def to_s(cents) when is_integer(cents) do
    dollars = floor(cents * 1.0 / 100)
    cents = cents - (dollars * 100)
    cents = String.pad_leading("#{cents}", 2, "0")
    "#{dollars}.#{cents}"
  end

  def to_cents(dollars_string) when is_binary(dollars_string) do
    {float, _} = Float.parse(dollars_string)
    round(float * 100)
  end
end
