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

    find_lowest_score(map, start_position)
  end

  def find_lowest_score(map, start_position) do
    q = :queue.new()

    visited = Map.new()
    visited = Map.put(visited, {start_position, {0, 1}}, 0)

    q = :queue.in({start_position, {0, 1}, 0}, q)

    Stream.unfold({q, visited}, fn {q, visited} ->
      case :queue.out(q) do
        {:empty, _q} ->
          nil

        {{:value, {{x, y} = position, direction, cost_so_far}}, q} ->
          if Map.get(map, position) == "E" do
            {cost_so_far, {q, visited}}
          else
            {new_q, new_visited} =
              next_directions(direction)
              |> Enum.reduce({q, visited}, fn {{dx, dy} = next_direction, cost}, {q, visited} ->
                next_position = {x + dx, y + dy}
                cost = cost_so_far + cost + 1

                if Map.get(map, next_position) != "#" and
                     Map.get(visited, {next_position, next_direction}, :infinity) > cost do
                  {:queue.in({next_position, next_direction, cost}, q),
                   Map.put(visited, {next_position, next_direction}, cost)}
                else
                  {q, visited}
                end
              end)

            {nil, {new_q, new_visited}}
          end
      end
    end)
    |> Enum.min()
  end

  def next_directions({-1, 0} = d), do: [{d, 0}, {{0, -1}, 1000}, {{0, 1}, 1000}]
  def next_directions({1, 0} = d), do: [{d, 0}, {{0, 1}, 1000}, {{0, -1}, 1000}]
  def next_directions({0, -1} = d), do: [{d, 0}, {{-1, 0}, 1000}, {{1, 0}, 1000}]
  def next_directions({0, 1} = d), do: [{d, 0}, {{1, 0}, 1000}, {{-1, 0}, 1000}]

  def p2(_input) do
  end
end
