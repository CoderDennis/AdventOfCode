import AOC

alias Helpers.CoordinateMap

aoc 2024, 12 do
  def p1(input) do
    map =
      input
      |> CoordinateMap.create()

    {regions, _visited} =
      map
      |> Enum.reduce({[], MapSet.new()}, fn {plot, plant_type}, {regions, visited} ->
        # visited set of plots, use DFS to see what all is connected for a given region
        IO.inspect(visited)

        case MapSet.member?(visited, plot) do
          true ->
            {regions, visited}

          false ->
            {region, visited} = explore_region(plot, plant_type, map, visited)
            {[region | regions], visited}
        end

        {regions, visited}
      end)

    regions
    |> IO.inspect()
    |> Enum.map(fn {_plant_type, plots} = region ->
      area = Enum.count(plots)
      perimeter = perimeter(region, map)
      # IO.inspect({plant_type, area, perimeter})
      area * perimeter
    end)
    |> Enum.sum()
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def explore_region({r, c} = plot, plant_type, map, visited) do
    # IO.inspect({plot, plant_type, visited})

    plots_to_explore =
      @directions
      |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
      |> Enum.filter(fn other_plot ->
        Map.get(map, other_plot) == plant_type and not MapSet.member?(visited, other_plot)
      end)
      |> IO.inspect()

    visited = MapSet.put(visited, plot) |> IO.inspect()

    {region_plots, visited} =
      plots_to_explore
      |> Enum.reduce({MapSet.new([plot]), visited}, fn other_plot, {plots, visited} ->
        {{_, region_plots}, visited} = explore_region(other_plot, plant_type, map, visited)
        {MapSet.union(plots, region_plots), visited}
      end)

    {{plant_type, region_plots}, visited}
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
