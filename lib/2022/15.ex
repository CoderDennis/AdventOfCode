import AOC

aoc 2022, 15 do
  def p1 do
    sensors =
      input_stream()
      |> parse_input()

    {{min_x, max_x}, beacons} =
      sensors
      |> Enum.reduce({{0, 0}, MapSet.new()}, &find_x_extent_and_beacons/2)

    # check_y = 10
    check_y = 2_000_000

    # filled
    # |> Enum.reduce(0, fn
    #   {_x, ^check_y} = position, count ->
    #     IO.inspect(position)
    #     if MapSet.member?(beacons, position), do: count, else: count + 1

    #   _, count ->
    #     count
    # end)
    min_x..max_x
    |> Enum.reduce(0, fn x, count ->
      if Enum.find(sensors, fn {x1, y1, _, _} = sensor ->
           distance(sensor) >= distance({x1, y1, x, check_y})
         end) != nil do
        if MapSet.member?(beacons, {x, check_y}), do: count, else: count + 1
      else
        count
      end
    end)
  end

  def p2 do
    sensors =
      input_stream()
      |> parse_input()

    sensors_with_distance =
      sensors
      |> Enum.map(fn {x, y, _, _} = sensor ->
        {x, y, distance(sensor)}
      end)

    # max_coord = 20
    max_coord = 4_000_000

    # {x, y} =
    #   for(
    #     x <- 0..max_coord,
    #     y <- 0..max_coord,
    #     do: {x, y}
    #   )
    #   |> Enum.find(fn {x, y} ->
    #     sensors_with_distance
    #     |> Enum.find(fn {x1, y1, distance} ->
    #       distance({x1, y1, x, y}) <= distance
    #     end) == nil
    #   end)
    0..max_coord
    |> Task.async_stream(
      fn x ->
        0..max_coord
        |> Enum.each(fn y ->
          if sensors_with_distance
             |> Enum.find(fn {x1, y1, distance} ->
               distance({x1, y1, x, y}) <= distance
             end) == nil do
            IO.inspect({x, y, x * 4_000_000 + y})
          end
        end)
      end,
      timeout: :infinity
    )
    |> Stream.run()
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

  def find_x_extent_and_beacons({x1, _y1, x2, y2} = sensor, {{min_x, max_x}, beacons}) do
    distance = IO.inspect(distance(sensor))

    {{min(x1 - distance, min_x), max(x1 + distance, max_x)}, MapSet.put(beacons, {x2, y2})}
  end

  def distance({x1, y1, x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
