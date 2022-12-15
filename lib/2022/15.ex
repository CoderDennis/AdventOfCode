import AOC

aoc 2022, 15 do
  def p1 do
    {filled, beacons} =
      example_stream()
      |> parse_input()
      |> Enum.reduce({MapSet.new(), MapSet.new()}, &fill_sensor_area/2)

    # 2_000_000
    check_y = 10

    filled
    |> Enum.reduce(0, fn
      {_x, ^check_y} = position, count ->
        IO.inspect(position)
        if MapSet.member?(beacons, position), do: count, else: count + 1

      _, count ->
        count
    end)
  end

  def p2 do
  end

  def parse_input(stream) do
    stream
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [_, _, "x=" <> sx, "y=" <> sy, _, _, _, _, "x=" <> bx, "y=" <> by] ->
      {sx |> String.trim_trailing(",") |> String.to_integer(),
       sy |> String.trim_trailing(":") |> String.to_integer(),
       bx |> String.trim_trailing(",") |> String.to_integer(), String.to_integer(by)}
    end)
  end

  def fill_sensor_area({x1, y1, x2, y2} = sensor, {filled, beacons}) do
    # filled and beacons should be MapSet instances
    distance = IO.inspect(distance(sensor))

    {-distance..distance
     |> Enum.reduce(filled, fn x, filled ->
       y = distance - abs(x)

       -y..y
       |> Enum.reduce(filled, fn y, filled ->
         MapSet.put(filled, {x + x1, y + y1})
       end)
     end), MapSet.put(beacons, {x2, y2})}
  end

  def distance({x1, y1, x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
