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

    {picoseconds_with_no_cheat, _} =
      times_to_exit_with_cheat(map, start_position, :used) |> Enum.at(0)

    IO.inspect(picoseconds_with_no_cheat)

    picoseconds_with_cheat = times_to_exit_with_cheat(map, start_position)

    {picoseconds_with_no_cheat, picoseconds_with_cheat}

    picoseconds_with_cheat
    |> Enum.map(&(picoseconds_with_no_cheat - elem(&1, 0)))
    |> Enum.filter(&(&1 >= 100))
    |> Enum.count()
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def times_to_exit_with_cheat(map, start_position, cheat_status \\ :available) do
    q = :queue.new()

    q = :queue.in({start_position, 0, cheat_status, [], MapSet.new([start_position])}, q)

    Stream.unfold(q, fn q ->
      case :queue.out(q) do
        {:empty, _q} ->
          nil

        {{:value, {{x, y} = position, time_so_far, cheat_status, cheat_positions, path}} = _value,
         q} ->
          # IO.inspect(value)
          # if cheat_status == :active do
          #   IO.inspect({position, cheat_status})
          # end

          if Map.get(map, position) == "E" do
            {{time_so_far, cheat_positions}, q}
          else
            new_q =
              @directions
              |> Enum.reduce(q, fn {dx, dy} = _next_direction, q ->
                next_position = {x + dx, y + dy}

                if Map.has_key?(map, next_position) and
                     not MapSet.member?(path, next_position) do
                  time = time_so_far + 1

                  {next_cheat_status, can_move} =
                    can_move?(cheat_status, Map.get(map, next_position))

                  cheat_positions =
                    case {cheat_status, next_cheat_status} do
                      {:available, :used} -> [position, next_position]
                      _ -> cheat_positions
                    end

                  if can_move do
                    :queue.in(
                      {next_position, time, next_cheat_status, cheat_positions,
                       MapSet.put(path, next_position)},
                      q
                    )
                  else
                    q
                  end
                else
                  q
                end
              end)

            {nil, new_q}
          end
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.uniq()
  end

  # cheat status is like a state machine :available -> :used
  # first match is to prevent the edge case of revisiting start position
  def can_move?(status, "S"), do: {status, false}

  def can_move?(:available, "."), do: {:available, true}
  def can_move?(:available, "E"), do: {:available, true}
  def can_move?(:available, "#"), do: {:used, true}

  def can_move?(:used, position_value), do: {:used, position_value != "#"}

  def p2(input) do
    map =
      input
      |> CoordinateMap.create()

    {end_position, _} =
      map
      |> Enum.find(fn
        {_, "E"} -> true
        _ -> false
      end)

    times_to_end =
      times_to_end_with_no_cheat(map, end_position)

    # example should give 285 that save 50 or more
    # 254581 and 475381 were too low
    cheats =
      find_cheats(times_to_end)
      |> Enum.filter(fn {_, time} -> time >= 100 end)
      |> Enum.uniq_by(&elem(&1, 0))

    # cheats
    # |> Enum.reduce(%{}, fn {_, k}, map ->
    #   Map.update(map, k, 1, fn v -> v + 1 end)
    # end)
    # |> IO.inspect()

    cheats
    |> Enum.count()
  end

  def times_to_end_with_no_cheat(map, end_position) do
    Stream.unfold({end_position, 0, MapSet.new()}, fn
      {nil, _, _} ->
        nil

      {{x, y} = position, time_to_end, visited} ->
        next_position =
          @directions
          |> Enum.map(fn {dx, dy} = _next_direction ->
            {x + dx, y + dy}
          end)
          |> Enum.reject(&MapSet.member?(visited, &1))
          |> Enum.find(fn position ->
            Map.get(map, position) != "#"
          end)

        {{position, time_to_end}, {next_position, time_to_end + 1, MapSet.put(visited, position)}}
    end)
    |> Map.new()
  end

  def find_cheats(times_to_end) do
    possible_cheats =
      for start_position <- times_to_end,
          end_position <- times_to_end,
          start_position != end_position,
          do: {start_position, end_position}

    possible_cheats
    |> Enum.filter(fn {{{x1, y1}, _}, {{x2, y2}, _}} ->
      # manhattan distance no greater than 20
      abs(x1 - x2) + abs(y1 - y2) <= 20
    end)
    |> Enum.map(fn {{{x1, y1} = start_position, start_time_to_end},
                    {{x2, y2} = end_position, end_time_to_end}} ->
      {{start_position, end_position},
       start_time_to_end - end_time_to_end - (abs(x1 - x2) + abs(y1 - y2))}
    end)
  end
end
