defmodule Vending.Utils do

  @doc """
  returns an array of
  5, 10, 20, 50 and 100 cent coins
  """
  def calculate_return(amount) do
    with {hundred, extra} <- split_to_units(amount, 100),
         {fifty, extra} <- split_to_units(extra, 50),
         {twenty, extra} <- split_to_units(extra, 20),
         {ten, extra} <- split_to_units(extra, 10),
         {five, _extra} <- split_to_units(extra, 5)
    do
      [five, ten, twenty, fifty, hundred]
    end
  end

  defp split_to_units(number, divisor) do
    {Integer.floor_div(number, divisor), Integer.mod(number, divisor)}
  end
end
