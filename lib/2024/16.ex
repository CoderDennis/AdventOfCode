import AOC

alias Helpers.CoordinateMap

aoc 2024, 16 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    {start_position, _} =
      map
      |> Enum.find(fn
        {_, "S"} -> true
        _ -> false
      end)

    # CoordinateMap.draw(map)

    {score, _} = find_lowest_score(start_position, {0, 1}, map, 0, MapSet.new())
    score
  end

  def find_lowest_score({x, y} = position, direction, map, score, visited) do
    # IO.inspect({position, direction})
    # IO.inspect(visited)

    if Map.get(map, position) == "E" do
      {score, visited}
    else
      visited = MapSet.put(visited, position)

      next_directions(direction)
      |> Enum.map(fn {{dx, dy} = next_direction, cost} ->
        next_position = {x + dx, y + dy}

        if Map.get(map, next_position) != "#" and
             not MapSet.member?(visited, next_position) do
          find_lowest_score(next_position, next_direction, map, score + cost + 1, visited)
        else
          {:infinity, visited}
        end
      end)
      |> Enum.min_by(&elem(&1, 0))
    end
  end

  def next_directions({-1, 0} = d), do: [{d, 0}, {{0, -1}, 1000}, {{0, 1}, 1000}]
  def next_directions({1, 0} = d), do: [{d, 0}, {{0, 1}, 1000}, {{0, -1}, 1000}]
  def next_directions({0, -1} = d), do: [{d, 0}, {{-1, 0}, 1000}, {{1, 0}, 1000}]
  def next_directions({0, 1} = d), do: [{d, 0}, {{1, 0}, 1000}, {{-1, 0}, 1000}]

  def p2(_input) do
  end
end
