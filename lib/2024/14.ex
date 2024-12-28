import AOC

aoc 2024, 14 do
  # too low answer:
  # 212979000
  def p1(input) do
    x_width = 101
    y_height = 103

    x_middle = div(x_width, 2)
    y_middle = div(y_height, 2)

    end_positions =
      input
      |> parse_input()
      # |> IO.inspect()
      |> Enum.map(&end_position(&1, x_width, y_height, 100))

    draw_map(end_positions, x_width, y_height)

    end_positions
    |> Enum.reduce([0, 0, 0, 0], fn position, [q1, q2, q3, q4] ->
      case position do
        {x, y} when x < x_middle and y < y_middle ->
          [q1 + 1, q2, q3, q4]

        {x, y} when x > x_middle and y < y_middle ->
          [q1, q2 + 1, q3, q4]

        {x, y} when x < x_middle and y > y_middle ->
          [q1, q2, q3 + 1, q4]

        {x, y} when x > x_middle and y > y_middle ->
          [q1, q2, q3, q4 + 1]

        other ->
          IO.inspect(other)
          [q1, q2, q3, q4]
      end
    end)
    |> IO.inspect()
    |> Enum.product()
  end

  def draw_map(positions, x_width, y_height) do
    position_counts =
      positions
      |> Enum.reduce(%{}, fn position, map ->
        Map.update(map, position, 1, &(&1 + 1))
      end)

    0..y_height
    |> Enum.map(fn y ->
      0..x_width
      |> Enum.map(fn x ->
        case Map.get(position_counts, {x, y}) do
          nil -> IO.write(".")
          count -> IO.write("#{count}")
        end
      end)

      IO.write("\n")
    end)

    IO.write("\n")
  end

  def end_position({{px, py}, {vx, vy}}, x_width, y_height, seconds) do
    {Integer.mod(vx * seconds + px, x_width), Integer.mod(vy * seconds + py, y_height)}
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      ~r/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/
      |> Regex.run(line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [px, py, vx, vy] -> {{px, py}, {vx, vy}} end)
  end

  def p2(input) do
    robots =
      input
      |> parse_input()

    draw_one_second(robots, 1)
  end

  def draw_one_second(robots, seconds) do
    IO.inspect(seconds)

    map =
      robots
      |> Enum.map(&end_position(&1, 101, 103, seconds))

    if top_to_bottom_ratio(map, 103) < 0.3 do
      map
      |> draw_map(101, 103)

      IO.gets("#{seconds} : is this a christmas tree? Hit enter to continue.")
    end

    draw_one_second(robots, seconds + 1)
  end

  def top_to_bottom_ratio(map, y_height) do
    # majority of pixels should be in bottom half of the image
    y_middle = div(y_height, 2)

    [top, bottom] =
      map
      |> Enum.reduce([0, 0], fn position, [top, bottom] ->
        case position do
          {_x, y} when y < y_middle ->
            [top + 1, bottom]

          {_x, y} when y > y_middle ->
            [top, bottom + 1]

          _other ->
            [top, bottom]
        end
      end)

    top / bottom
  end
end
