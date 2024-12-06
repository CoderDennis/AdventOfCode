import AOC

alias Helpers.CoordinateMap

aoc 2024, 6 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    {position, _guard} =
      Map.filter(map, fn
        {_, "."} -> false
        {_, "#"} -> false
        _ -> true
      end)
      |> Enum.at(0)

    guard_path(position, {-1, 0}, map, MapSet.new())
    |> Enum.count()
  end

  defp guard_path({r, c} = position, {dr, dc} = direction, map, path) do
    path = MapSet.put(path, position)
    next_position = {r + dr, c + dc}

    if not Map.has_key?(map, next_position) do
      path
    else
      if Map.get(map, next_position) == "#" do
        {dr, dc} = direction = turn_right(direction)
        next_position = {r + dr, c + dc}
        guard_path(next_position, direction, map, path)
      else
        guard_path(next_position, direction, map, path)
      end
    end
  end

  defp turn_right({-1, 0}), do: {0, 1}
  defp turn_right({0, 1}), do: {1, 0}
  defp turn_right({1, 0}), do: {0, -1}
  defp turn_right({0, -1}), do: {-1, 0}

  def p2(input) do
    # 1455 was too low
    # 1467 also too low
    map =
      input
      |> CoordinateMap.create()

    {position, _guard} =
      Map.filter(map, fn
        {_, "."} -> false
        {_, "#"} -> false
        _ -> true
      end)
      |> Enum.at(0)

    map
    |> Enum.map(fn
      {empty_position, "."} ->
        alt_map = Map.put(map, empty_position, "#")
        guard_path_contains_loop(position, {-1, 0}, alt_map, MapSet.new())

      _ ->
        0
    end)
    |> Enum.sum()
  end

  defp guard_path_contains_loop({r, c} = position, {dr, dc} = direction, map, path) do
    if MapSet.member?(path, {position, direction}) do
      # IO.inspect({position, direction}, label: "loop found")
      1
    else
      path = MapSet.put(path, {position, direction})
      next_position = {r + dr, c + dc}

      if not Map.has_key?(map, next_position) do
        # IO.inspect({next_position, direction}, label: "exit")
        0
      else
        if Map.get(map, next_position) == "#" do
          guard_path_contains_loop(position, turn_right(direction), map, path)
        else
          guard_path_contains_loop(next_position, direction, map, path)
        end
      end
    end
  end
end
