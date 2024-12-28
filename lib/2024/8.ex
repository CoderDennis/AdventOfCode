import AOC

alias Helpers.CoordinateMap

aoc 2024, 8 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    antennas =
      map
      |> Enum.reduce(%{}, fn
        {_, "."}, antenna_map ->
          antenna_map

        {coord, antenna}, antenna_map ->
          Map.update(antenna_map, antenna, [coord], fn list -> [coord | list] end)
      end)

    antennas
    |> Enum.flat_map(fn {_freq, coords} -> antinodes(coords) end)
    |> Enum.filter(fn x -> Map.has_key?(map, x) end)
    |> MapSet.new()
    |> Enum.count()
  end

  defp antinodes(antenna_coords) do
    antenna_coords
    |> get_pairs
    |> Enum.flat_map(&find_antinodes_for_pair/1)
  end

  def find_antinodes_for_pair({{ax, ay}, {bx, by}}) do
    [
      {ax - (bx - ax), ay + ay - by},
      {bx + bx - ax, by - (ay - by)}
    ]
  end

  defp get_pairs(list), do: get_pairs([], list)

  defp get_pairs(pairs, []), do: pairs

  defp get_pairs(pairs, [head | rest]) do
    Enum.reduce(rest, pairs, fn x, acc -> [{head, x} | acc] end)
    |> get_pairs(rest)
  end

  def p2(input) do
    map =
      input
      |> CoordinateMap.create()

    antennas =
      map
      |> Enum.reduce(%{}, fn
        {_, "."}, antenna_map ->
          antenna_map

        {coord, antenna}, antenna_map ->
          Map.update(antenna_map, antenna, [coord], fn list -> [coord | list] end)
      end)

    antennas
    |> Enum.flat_map(fn {_freq, coords} -> antinodes(coords, map) end)
    |> MapSet.new()
    |> Enum.count()
  end

  defp antinodes(antenna_coords, map) do
    antenna_coords
    |> get_pairs
    |> Enum.flat_map(&find_all_antinodes_for_pair(&1, map))
  end

  def find_all_antinodes_for_pair({{ax, ay} = a, {bx, by}}, map) do
    slope_x = bx - ax
    slope_y = ay - by

    a
    |> Stream.unfold(fn {x, y} = location ->
      case Map.has_key?(map, location) do
        true -> {location, {x - slope_x, y + slope_y}}
        false -> nil
      end
    end)
    |> Enum.reverse()
    |> Enum.at(0)
    |> Stream.unfold(fn {x, y} = location ->
      case Map.has_key?(map, location) do
        true -> {location, {x + slope_x, y - slope_y}}
        false -> nil
      end
    end)
  end
end
