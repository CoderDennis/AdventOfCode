import AOC

aoc 2022, 8 do
  def p1 do
    grid = read_input()

    rows = map_size(grid)
    cols = map_size(grid[0])
    edge_count = rows * 2 + cols * 2 - 4

    interior_count =
      1..(rows - 2)
      |> Enum.reduce(0, fn row, count ->
        (1..(cols - 2)
         |> Enum.reduce(0, fn col, col_count ->
           col_count + tree_visible(grid, row, col)
         end)) + count
      end)

    interior_count + edge_count
  end

  def p2 do
    grid = read_input()

    rows = map_size(grid)
    cols = map_size(grid[0])

    0..(rows - 1)
    |> Enum.flat_map(fn row ->
      0..(cols - 1)
      |> Enum.map(fn col ->
        scenic_score(grid, row, col)
      end)
    end)
    |> Enum.max()
  end

  defp tree_visible(grid, row, col) do
    tree = grid[row][col]
    rows = map_size(grid)
    cols = map_size(grid[0])

    up =
      0..(row - 1)
      |> Enum.all?(fn r -> grid[r][col] < tree end)

    if up do
      1
    else
      down =
        (row + 1)..(rows - 1)
        |> Enum.all?(fn r -> grid[r][col] < tree end)

      if down do
        1
      else
        left =
          0..(col - 1)
          |> Enum.all?(fn c -> grid[row][c] < tree end)

        if left do
          1
        else
          right =
            (col + 1)..(cols - 1)
            |> Enum.all?(fn c -> grid[row][c] < tree end)

          if right do
            1
          else
            0
          end
        end
      end
    end
  end

  defp scenic_score(grid, row, col) do
    tree = grid[row][col]
    rows = map_size(grid)
    cols = map_size(grid[0])

    # IO.inspect({tree, row, col})

    up =
      if row == 0,
        do: 0,
        else:
          (row - 1)..0
          |> Enum.map(fn r -> grid[r][col] end)
          |> Enum.reduce_while(0, fn t, acc -> reducer(t, tree, acc) end)

    down =
      if row == rows - 1,
        do: 0,
        else:
          (row + 1)..(rows - 1)
          |> Enum.map(fn r -> grid[r][col] end)
          |> Enum.reduce_while(0, fn t, acc -> reducer(t, tree, acc) end)

    left =
      if col == 0,
        do: 0,
        else:
          (col - 1)..0
          |> Enum.map(fn c -> grid[row][c] end)
          |> Enum.reduce_while(0, fn t, acc -> reducer(t, tree, acc) end)

    right =
      if col == cols - 1,
        do: 0,
        else:
          (col + 1)..(cols - 1)
          |> Enum.map(fn c -> grid[row][c] end)
          |> Enum.reduce_while(0, fn t, acc -> reducer(t, tree, acc) end)

    answer = up * down * left * right

    IO.inspect({row, col, up, down, left, right, answer})

    answer
  end

  defp reducer(t, tree, acc) do
    if t < tree do
      {:cont, acc + 1}
    else
      if t >= tree do
        {:halt, acc + 1}
      else
        {:halt, acc}
      end
    end
  end

  defp read_input() do
    input_stream()
    |> Stream.map(&String.codepoints/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, row}, map ->
      Map.put(
        map,
        row,
        line
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {tree, col}, row_map ->
          Map.put(row_map, col, String.to_integer(tree))
        end)
      )
    end)
  end
end
