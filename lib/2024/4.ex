import AOC

alias Helpers.CoordinateMap

aoc 2024, 4 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    map
    |> Enum.map(fn
      {position, "X"} ->
        search_all_directions(map, position)

      _ ->
        0
    end)
    |> Enum.sum()
  end

  defp search_all_directions(map, position) do
    rest = String.codepoints("MAS")

    -1..1
    |> Enum.flat_map(fn r ->
      -1..1
      |> Enum.map(fn c -> {r, c} end)
    end)
    |> Enum.filter(fn
      {0, 0} -> false
      _ -> true
    end)
    |> Enum.map(&find_word(&1, map, position, rest))
    |> Enum.sum()
  end

  defp find_word(_, _, _, []), do: 1

  defp find_word({dr, dc} = direction, map, {r, c}, [next | rest]) do
    next_pos = {r + dr, c + dc}

    if Map.has_key?(map, next_pos) and map[next_pos] == next do
      find_word(direction, map, next_pos, rest)
    else
      0
    end
  end

  def p2(input) do
    map =
      input
      |> CoordinateMap.create()

    map
    |> Enum.map(fn
      {position, "A"} ->
        find_x(map, position)

      _ ->
        0
    end)
    |> Enum.sum()
  end

  defp find_x(map, {r, c}) do
    if [[{r - 1, c - 1}, {r + 1, c + 1}], [{r - 1, c + 1}, {r + 1, c - 1}]]
       |> Enum.all?(fn [a, b] ->
         Map.has_key?(map, a) and Map.has_key?(map, b) and
           ["M", "S"] ==
             [map[a], map[b]]
             |> Enum.sort()
       end) do
      1
    else
      0
    end
  end
end
