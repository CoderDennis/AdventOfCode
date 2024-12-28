import AOC

aoc 2022, 14 do
  def p1(input) do
    rocks =
      parse_input(input)
      |> find_rocks()

    # |> IO.inspect()

    max_depth =
      rocks
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    pour_sand(rocks, max_depth)
    |> Enum.count()
  end

  def p2(input) do
    rocks =
      parse_input(input)
      |> find_rocks()

    # |> IO.inspect()

    max_depth =
      rocks
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    pour_sand(rocks, max_depth + 1)
    |> Enum.count()
  end

  def pour_sand(rocks, max_depth) do
    # returns collection of sand that comes to rest
    # stops based on which base case below is uncommented
    Stream.repeatedly(fn -> {500, 0} end)
    |> Enum.reduce_while(MapSet.new(), fn position, sand ->
      falling_sand(sand, rocks, max_depth, position)
    end)
  end

  # part 1 base case
  # def falling_sand(sand, _, max_depth, {_, sand_y}) when sand_y > max_depth, do: {:halt, sand}

  # part 2 base case
  def falling_sand(sand, _, max_depth, {_, sand_y} = position) when sand_y == max_depth,
    do: {:cont, MapSet.put(sand, position)}

  def falling_sand(sand, rocks, max_depth, {sand_x, sand_y} = position) do
    filled_tiles = MapSet.union(sand, rocks)
    down = {sand_x, sand_y + 1}
    down_left = {sand_x - 1, sand_y + 1}
    down_right = {sand_x + 1, sand_y + 1}

    cond do
      not MapSet.member?(filled_tiles, down) ->
        falling_sand(sand, rocks, max_depth, down)

      not MapSet.member?(filled_tiles, down_left) ->
        falling_sand(sand, rocks, max_depth, down_left)

      not MapSet.member?(filled_tiles, down_right) ->
        falling_sand(sand, rocks, max_depth, down_right)

      position == {500, 0} ->
        # only used for part 2
        {:halt, MapSet.put(sand, position)}

      true ->
        {:cont, MapSet.put(sand, position)}
    end
  end

  def find_rocks(scan) do
    scan
    |> Enum.flat_map(fn path ->
      path
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(&rock_path/1)
    end)
    |> MapSet.new()
  end

  def rock_path([{x1, y1}, {x1, y2}]) do
    y1..y2
    |> Enum.map(&{x1, &1})
  end

  def rock_path([{x1, y1}, {x2, y1}]) do
    x1..x2
    |> Enum.map(&{&1, y1})
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn point ->
        point
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
  end
end
