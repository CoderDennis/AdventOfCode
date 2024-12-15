defmodule Helpers.CoordinateMap do
  @doc """
  takes the input as a string, splits it into lines, and creates a map indexed by {row, col} coordinates

  `map` is a function to call on each character of the input and defaults to identity
  """
  def create(input, map \\ fn x -> x end) do
    input
    |> String.split("\n")
    |> create_from_lines(map)
  end

  @doc """
  takes the input as an enumerable of strings and creates a map indexed by {row, col} coordinates

  `map` is a function to call on each character of the input and defaults to identity
  """
  def create_from_lines(lines, map \\ fn x -> x end) do
    lines
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

  @doc """
  Outputs contents of map via IO functions
  """
  def draw(map) do
    max_x =
      map
      |> Enum.map(fn {{x, _}, _} -> x end)
      |> Enum.max()

    max_y =
      map
      |> Enum.map(fn {{_, y}, _} -> y end)
      |> Enum.max()

    0..max_x
    |> Enum.each(fn x ->
      0..max_y
      |> Enum.each(fn y ->
        case Map.get(map, {x, y}) do
          nil -> IO.write(".")
          value -> IO.write("#{value}")
        end
      end)

      IO.write("\n")
    end)
  end
end
