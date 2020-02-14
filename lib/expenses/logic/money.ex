defmodule Expenses.Money do
  def cents_to_dollars(cents) do
    (cents * 1.0 / 100) |> Float.round(2)
  end

  def eur_to_usd(eur) do
    (eur * 1.1) |> Float.round(2)
  end

  def usd_to_eur(usd) do
    (usd * 1.0 / 1.1) |> Float.round(2)
  end
end
