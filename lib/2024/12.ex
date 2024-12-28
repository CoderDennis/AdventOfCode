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

  def p2(input) do
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
      sides = count_sides(region, map)
      # IO.inspect({plant_type, area, sides})
      area * sides
    end)
    |> Enum.sum()
  end

  def count_sides({plant_type, plots}, map) do
    # visited needs to include direction and the top/left edge of the side because corner plots are part of 2 sides
    plots
    |> Enum.reduce(MapSet.new(), fn {r, c} = plot, visited ->
      @directions
      |> Enum.reduce(visited, fn {dr, dc} = direction, visited ->
        other_plot = {r + dr, c + dc}

        if Map.get(map, other_plot) != plant_type do
          # on a side
          if MapSet.member?(visited, {plot, direction}) do
            # already counted this side
            visited
          else
            # find top/left edge of current side in given direction.
            {move_r, move_c} =
              case direction do
                {0, _dc} ->
                  # move up to find top
                  {-1, 0}

                {_dr, 0} ->
                  # move left to find left
                  {0, -1}
              end

            top_left =
              plot
              |> Stream.unfold(fn {r, c} = side_plot ->
                other_side_plot = {r + dr, c + dc}

                if Map.get(map, side_plot) == plant_type and
                     Map.get(map, other_side_plot) != plant_type do
                  {side_plot, {r + move_r, c + move_c}}
                else
                  nil
                end
              end)
              |> Enum.at(-1)

            # add side to visited set
            MapSet.put(visited, {top_left, direction})
          end
        else
          # not on a side
          visited
        end
      end)
    end)
    |> MapSet.size()
  end
end
