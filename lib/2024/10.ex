import AOC

alias Helpers.CoordinateMap

aoc 2024, 10 do
  def p1(input) do
    #     input = "0123
    # 1234
    # 8765
    # 9876"

    map =
      input
      |> CoordinateMap.create(&String.to_integer/1)

    map
    |> Enum.filter(fn
      {_, 0} -> true
      _ -> false
    end)
    |> Enum.map(&find_reachable_9_height_positions(&1, map, MapSet.new()))
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()

    # |> Enum.reduce(0, fn trailhead, count -> count + find_trails(trailhead, map) end)
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def find_reachable_9_height_positions({position, 9}, _map, result),
    do: MapSet.put(result, position)

  def find_reachable_9_height_positions({{r, c}, height}, map, result) do
    # IO.inspect({r, c})

    @directions
    |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
    |> Enum.filter(fn next_position ->
      case Map.get(map, next_position) do
        next_height when next_height - 1 == height -> true
        _ -> false
      end
    end)
    |> Enum.reduce(result, fn next_position, result ->
      find_reachable_9_height_positions(
        {next_position, Map.get(map, next_position)},
        map,
        result
      )
    end)
  end

  def p2(_input) do
  end
end
