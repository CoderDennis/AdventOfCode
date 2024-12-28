import AOC

alias Helpers.CoordinateMap

aoc 2024, 15 do
  def p1(input) do
    {map_lines, move_lines} =
      input
      |> String.split("\n")
      |> Enum.split_while(fn line -> line != "" end)

    map = CoordinateMap.create_from_lines(map_lines)

    {start, _} =
      map
      |> Enum.find(fn {_, x} -> x == "@" end)
      |> IO.inspect()

    move_lines
    |> Enum.join()
    |> String.codepoints()
    |> move(start, map)
    |> Enum.map(fn
      {{x, y}, "O"} -> x * 100 + y
      _ -> 0
    end)
    |> Enum.sum()
  end

  def move([], _position, map), do: map

  def move([move | moves], {x, y} = position, map) do
    # IO.inspect(move)
    # CoordinateMap.draw(map)

    {dx, dy} = direction(move)

    next_position = {x + dx, y + dy}

    case Map.get(map, next_position) do
      "." ->
        updated_map =
          map
          |> Map.put(position, ".")
          |> Map.put(next_position, "@")

        move(moves, next_position, updated_map)

      "O" ->
        # push boxes if possible

        # find an empty space in direction
        possible_empty_position =
          next_position
          |> Stream.unfold(fn pos ->
            case Map.get(map, {px, py} = pos) do
              "#" -> nil
              nil -> nil
              _ -> {pos, {px + dx, py + dy}}
            end
          end)
          |> Enum.find(fn pos -> Map.get(map, pos) == "." end)

        if Map.get(map, possible_empty_position) == "." do
          updated_map =
            map
            |> Map.put(possible_empty_position, "O")
            |> Map.put(position, ".")
            |> Map.put(next_position, "@")

          move(moves, next_position, updated_map)
        else
          # don't move
          move(moves, position, map)
        end

      _ ->
        # could be a wall or off the map, so don't move
        move(moves, position, map)
    end
  end

  def direction("<"), do: {0, -1}
  def direction("^"), do: {-1, 0}
  def direction(">"), do: {0, 1}
  def direction("v"), do: {1, 0}

  def p2(input) do
    {map_lines, move_lines} =
      input
      |> String.split("\n")
      |> Enum.split_while(fn line -> line != "" end)

    map = CoordinateMap.create_from_lines(map_lines)

    map =
      expand_map(map)

    {start, _} =
      map
      |> Enum.find(fn {_, x} -> x == "@" end)
      |> IO.inspect()

    final_map =
      move_lines
      |> Enum.join()
      |> String.codepoints()
      |> move2(start, map)

    IO.puts("final map: ")
    CoordinateMap.draw(final_map)

    final_map
    |> Enum.map(fn
      {{x, y}, "["} -> x * 100 + y
      _ -> 0
    end)
    |> Enum.filter(fn gps -> gps > 0 end)
    # |> IO.inspect()
    |> Enum.sum()
  end

  def move2([], _position, map), do: map

  def move2([move | moves], {x, y} = position, map) do
    # CoordinateMap.draw(map)
    # IO.inspect(move)
    # IO.gets("hit enter to continue")

    {dx, dy} = direction(move)

    {next_x, next_y} = next_position = {x + dx, y + dy}

    case Map.get(map, next_position) do
      "." ->
        updated_map =
          map
          |> Map.put(position, ".")
          |> Map.put(next_position, "@")

        move2(moves, next_position, updated_map)

      "#" ->
        move2(moves, position, map)

      box when (box == "[" or box == "]") and dx == 0 ->
        # IO.puts("left or right")

        possible_empty_position =
          next_position
          |> Stream.unfold(fn pos ->
            case Map.get(map, {px, py} = pos) do
              "#" -> nil
              nil -> nil
              _ -> {pos, {px + dx, py + dy}}
            end
          end)
          |> Enum.find(fn pos -> Map.get(map, pos) == "." end)

        if Map.get(map, possible_empty_position) == "." do
          {_, empty_y} = possible_empty_position

          updated_map =
            empty_y..y//dy * -1
            |> Enum.chunk_every(2, 1, :discard)
            # |> IO.inspect()
            |> Enum.reduce(map, fn [ya, yb], m ->
              Map.put(m, {x, ya}, Map.get(m, {x, yb}))
            end)
            |> Map.put(position, ".")
            |> Map.put(next_position, "@")

          move2(moves, next_position, updated_map)
        else
          move2(moves, position, map)
        end

      box when (box == "[" or box == "]") and dy == 0 ->
        # IO.puts("up or down")
        # must account for offset boxes

        {do_move, updated_map} =
          if box == "[" do
            [next_position, {next_x, next_y + 1}]
          else
            [{next_x, next_y - 1}, next_position]
          end
          |> push_boxes(dx, map)

        if do_move do
          map_with_moved_robot =
            updated_map
            |> Map.put(position, ".")
            |> Map.put(next_position, "@")

          # CoordinateMap.draw(map_with_moved_robot)
          # IO.inspect(moves)
          move2(moves, next_position, map_with_moved_robot)
        else
          move2(moves, position, map)
        end
    end
  end

  @doc """
  return {boolean, updated_map} where boolean is true if it was possible to move
  """
  def push_boxes(box_tiles, dx, map) do
    # IO.inspect({box_tiles, dx})
    # collect boxes until there are all empty spaces in the next row.
    # stop if any box hits a wall
    next_tiles =
      box_tiles
      |> Enum.map(fn {x, y} -> {x + dx, y} end)

    # |> IO.inspect()

    next_tile_values =
      next_tiles
      |> Enum.map(fn t -> Map.get(map, t) end)

    # |> IO.inspect()

    if Enum.any?(next_tile_values, fn t -> t == "#" end) do
      {false, map}
    else
      if Enum.all?(next_tile_values, fn t -> t == "." end) do
        # move boxes
        updated_map = move_row_of_boxes(map, dx, box_tiles)
        # CoordinateMap.draw(updated_map)

        {true, updated_map}
      else
        # collect next_row of boxes and pass to push_boxes
        next_tiles =
          next_tiles
          |> Enum.filter(fn t -> Map.get(map, t) != "." end)
          |> MapSet.new()
          |> Enum.reduce(MapSet.new(), fn {x, y} = tile, tile_set ->
            # find half boxes and include the other halves.
            case Map.get(map, tile) do
              "[" ->
                MapSet.put(tile_set, {x, y + 1})

              "]" ->
                MapSet.put(tile_set, {x, y - 1})
            end
            |> MapSet.put(tile)
          end)

        # if returns true, then move the current row of boxes
        case push_boxes(next_tiles, dx, map) do
          {true, updated_map} ->
            {true, move_row_of_boxes(updated_map, dx, box_tiles)}

          {false, _} ->
            {false, map}
        end
      end
    end
  end

  def move_row_of_boxes(map, dx, box_tiles) do
    box_tiles
    |> Enum.reduce(map, fn {x, y} = t, map ->
      map
      |> Map.put({x + dx, y}, Map.get(map, t))
      |> Map.put(t, ".")
    end)
  end

  def expand_map(map) do
    map
    |> Enum.flat_map(fn
      {{x, y}, "#"} -> [{{x, y * 2}, "#"}, {{x, y * 2 + 1}, "#"}]
      {{x, y}, "O"} -> [{{x, y * 2}, "["}, {{x, y * 2 + 1}, "]"}]
      {{x, y}, "."} -> [{{x, y * 2}, "."}, {{x, y * 2 + 1}, "."}]
      {{x, y}, "@"} -> [{{x, y * 2}, "@"}, {{x, y * 2 + 1}, "."}]
    end)
    |> Map.new()
  end
end
