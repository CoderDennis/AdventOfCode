import AOC

alias Helpers.CoordinateMap

aoc 2024, 20 do
  use Memoize

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

    # CoordinateMap.draw(map)

    {start_position, _} =
      map
      |> Enum.find(fn
        {_, "S"} -> true
        _ -> false
      end)

    {picoseconds_with_no_cheat, _} =
      times_to_exit_with_cheat_2(map, start_position, :used) |> Enum.at(0)

    picoseconds_with_cheat = times_to_exit_with_cheat_2(map, start_position)

    {picoseconds_with_no_cheat, picoseconds_with_cheat}

    # picoseconds_with_cheat
    # |> Enum.map(&(picoseconds_with_no_cheat - elem(&1, 0)))

    # |> Enum.filter(&(&1 >= 50))
    # |> Enum.count()
  end

  def times_to_exit_with_cheat_2(map, start_position, cheat_status \\ :available) do
    q = :queue.new()

    q = :queue.in({start_position, 0, cheat_status, [], MapSet.new()}, q)

    Stream.unfold({q, MapSet.new()}, fn {q, visited} ->
      case :queue.out(q) do
        {:empty, _q} ->
          nil

        {{:value, {position, time_so_far, cheat_status, cheat_positions, path}} = _value, q} ->
          if Map.get(map, position) == "E" do
            {{time_so_far, cheat_positions}, {q, visited}}
          else
            new_items_for_queue =
              do_times_to_exit(map, position, time_so_far, cheat_status, cheat_positions, path)

            new_visited =
              new_items_for_queue
              |> Enum.map(fn {position, _time, cheat_status, _cheat_positions, _path} ->
                {position, cheat_status}
              end)
              |> MapSet.new()
              |> MapSet.union(visited)

            q =
              new_items_for_queue
              |> :queue.from_list()
              |> :queue.join(q)

            {nil, {q, new_visited}}
          end
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.uniq()
  end

  def do_times_to_exit(
        map,
        {x, y} = position,
        time_so_far,
        cheat_status,
        cheat_positions,
        path
      ) do
    # IO.inspect({position, cheat_status})

    @directions
    |> Enum.map(fn {dx, dy} = _next_direction ->
      next_position = {x + dx, y + dy}
      time = time_so_far + 1

      {next_cheat_status, can_move} =
        can_move_2?(cheat_status, Map.get(map, next_position))

      cheat_positions =
        case {cheat_status, next_cheat_status} do
          {:available, _} -> [position]
          {count, :used} when is_integer(count) -> [next_position | cheat_positions]
          _ -> cheat_positions
        end

      if can_move and Map.has_key?(map, next_position) and
           not MapSet.member?(path, next_position) do
        {next_position, time, next_cheat_status, cheat_positions, MapSet.put(path, next_position)}
      else
        nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
  end

  # cheat status is like a state machine :available -> 20..1 -> :used
  # once a cheat is started, it must continue until track is found again
  # first match is to prevent the edge case of revisiting start position
  def can_move_2?(_, "S"), do: {:used, false}
  def can_move_2?(_, nil), do: {:used, false}

  def can_move_2?(:available, "."), do: {:available, true}
  def can_move_2?(:available, "E"), do: {:available, true}
  def can_move_2?(:available, "#"), do: {20, true}

  def can_move_2?(:used, position_value), do: {:used, position_value != "#"}

  def can_move_2?(1, "#"), do: {:used, false}

  def can_move_2?(count, "#"), do: {count - 1, true}

  def can_move_2?(_count, _), do: {:used, true}
end
