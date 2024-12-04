defmodule Helpers.CoordinateMap do
  @doc """
  takes the input and creates a map indexed by {row, col} coordinates
  """
  def create(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, r} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {char, c} ->
        {{r, c}, char}
      end)
    end)
    |> Map.new()
  end
end
