defmodule Helpers.CoordinateMap do
  @doc """
  takes the input and creates a map indexed by {row, col} coordinates

  `map` is a function to call on each character of the input and defaults to identity
  """
  def create(input, map \\ fn x -> x end) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {char, c} ->
        {{r, c}, map.(char)}
      end)
    end)
    |> Map.new()
  end
end
