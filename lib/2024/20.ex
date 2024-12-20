import AOC

alias Helpers.CoordinateMap

aoc 2024, 20 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    # CoordinateMap.draw(map)

    {start_position, _} =
      map
      |> Enum.find(fn
        {_, "S"} -> true
        _ -> false
      end)

    picoseconds_with_no_cheat = times_to_exit_with_cheat(map, start_position, :used) |> Enum.at(0)
    picoseconds_with_cheat = times_to_exit_with_cheat(map, start_position)

    IO.inspect({picoseconds_with_no_cheat, picoseconds_with_cheat})

    picoseconds_with_cheat
    |> Enum.map(&(picoseconds_with_no_cheat - &1))
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def times_to_exit_with_cheat(map, start_position, cheat_status \\ :available) do
    q = :queue.new()

    visited = MapSet.new([{start_position, cheat_status}])

    q = :queue.in({start_position, 0, cheat_status, []}, q)

    Stream.unfold({q, visited}, fn {q, visited} ->
      case :queue.out(q) do
        {:empty, q} ->
          {nil, {q, visited}}

        {{:value, {{x, y} = position, time_so_far, cheat_status, path}} = _value, q} ->
          # IO.inspect(value)
          if cheat_status == :active do
            IO.inspect({position, cheat_status})
          end

          if Map.get(map, position) == "E" do
            {{time_so_far, Enum.reverse(path)}, {q, visited}}
          else
            {new_q, new_visited} =
              @directions
              |> Enum.reduce({q, visited}, fn {dx, dy} = _next_direction, {q, visited} ->
                next_position = {x + dx, y + dy}
                time = time_so_far + 1

                {next_cheat_status, can_move} =
                  can_move?(cheat_status, Map.get(map, next_position))

                if Map.has_key?(map, next_position) and
                     not MapSet.member?(visited, {next_position, next_cheat_status}) do
                  if can_move do
                    {:queue.in(
                       {next_position, time, next_cheat_status, [next_position | path]},
                       q
                     ), MapSet.put(visited, {next_position, next_cheat_status})}
                  else
                    {q, visited}
                  end
                else
                  {q, visited}
                end
              end)

            {nil, {new_q, new_visited}}
          end
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.map(&elem(&1, 0))
  end

  # cheat status is like a state machine :available -> :active -> :used
  # if it's :active, then it must progress to the next state
  # first match is to prevent the edge case of revisiting start position
  def can_move?(status, "S"), do: {status, false}

  def can_move?(:available, "."), do: {:available, true}
  def can_move?(:available, "E"), do: {:available, true}
  def can_move?(:available, "#"), do: {:active, true}

  def can_move?(:active, _), do: {:used, true}

  def can_move?(:used, position_value), do: {:used, position_value != "#"}

  def p2(_input) do
  end
end
