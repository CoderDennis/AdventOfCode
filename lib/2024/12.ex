import AOC

alias Helpers.CoordinateMap

aoc 2024, 12 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    plots_by_plant_type =
      map
      |> Enum.reduce(%{}, fn {plot, plant_type}, regions ->
        Map.update(regions, plant_type, [plot], fn plots -> [plot | plots] end)
      end)

    plots_by_plant_type
    |> Enum.flat_map(&split_regions(&1, map))
    |> Enum.map(fn {plant_type, plots} = region ->
      count = Enum.count(plots)
      area = area(region, map)
      IO.inspect({plant_type, count, area})
      count * area
    end)
    |> Enum.sum()
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def split_regions({plant_type, plots}, _map) do
    [{plant_type, plots}]
  end

  def area({plant_type, plots}, map) do
    plots
    |> Enum.flat_map(fn {r, c} = _plot ->
      @directions
      |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
    end)
    |> Enum.filter(fn other_plot ->
      Map.get(map, other_plot) != plant_type
    end)
    |> Enum.count()
  end

  def p2(_input) do
  end
end
