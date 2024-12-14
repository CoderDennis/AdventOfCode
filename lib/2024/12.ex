import AOC

alias Helpers.CoordinateMap

aoc 2024, 12 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    {regions, _visited} =
      map
      |> Enum.reduce({[], MapSet.new()}, fn {plot, plant_type}, {regions, visited_plots} ->
        if MapSet.member?(visited_plots, plot) do
          {regions, visited_plots}
        else
          {region, visited} = fill_region(plot, plant_type, [], map, visited_plots)
          {[{plant_type, MapSet.new(region)} | regions], visited}
        end
      end)

    regions
    |> Enum.map(fn {_plant_type, plots} = region ->
      area = Enum.count(plots)
      perimeter = perimeter(region, map)
      # IO.inspect({plant_type, area, perimeter})
      area * perimeter
    end)
    |> Enum.sum()
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def fill_region({r, c} = plot, plant_type, region, map, visited) do
    visited = MapSet.put(visited, plot)
    region = [plot | region]

    @directions
    |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
    |> Enum.filter(fn next_plot ->
      Map.get(map, next_plot) == plant_type and not MapSet.member?(visited, next_plot)
    end)
    |> Enum.reduce({region, visited}, fn next_plot, {region, visited} ->
      fill_region(next_plot, plant_type, region, map, visited)
    end)
  end

  def perimeter({plant_type, plots}, map) do
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
