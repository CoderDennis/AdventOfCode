import AOC

aoc 2024, 23 do
  def p1(input) do
    network_map =
      input
      |> String.split("\n")
      |> Enum.reduce(%{}, fn line, map ->
        [a, b] =
          line
          |> String.split("-")

        map
        |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
        |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
      end)

    network_map
    |> Enum.reduce(MapSet.new(), fn {c, connected_set}, triples ->
      mutual_connections =
        connected_set
        |> Enum.filter(fn d ->
          Map.get(network_map, d)
          |> MapSet.member?(c)
        end)

      new_triples =
        for x <- mutual_connections,
            y <- mutual_connections,
            MapSet.member?(Map.get(network_map, x), y),
            do:
              [c, x, y]
              |> Enum.sort()

      new_triples
      |> MapSet.new()
      # |> IO.inspect()
      |> MapSet.union(triples)
    end)
    |> Enum.filter(fn triple ->
      Enum.any?(triple, &String.starts_with?(&1, "t"))
    end)
    |> Enum.count()
  end

  def p2(input) do
    pairs =
      input
      |> String.split("\n")
      |> Enum.map(&(String.split(&1, "-") |> Enum.sort()))
      |> IO.inspect()

    network_map =
      pairs
      |> Enum.reduce(%{}, fn [a, b], map ->
        map
        |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
        |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
      end)

    max_party(network_map)
    |> Enum.join(",")
  end

  def is_connected_party(set, network_map) do
    set
    |> Enum.all?(fn a ->
      set
      |> Enum.reject(fn b -> b == a end)
      |> Enum.all?(fn b ->
        network_map
        |> Map.get(a)
        |> MapSet.member?(b) and
          network_map
          |> Map.get(b)
          |> MapSet.member?(a)
      end)
    end)
  end

  def max_party(network_map) do
    network_map
    |> Enum.map(fn {c, connected_set} ->
      # find the max party that contains c
      connected_set
      |> Enum.reduce(MapSet.new([c]), fn other_c, max_found ->
        candidate_party =
          max_found
          |> MapSet.put(other_c)

        if is_connected_party(candidate_party, network_map) do
          candidate_party
        else
          max_found
        end
      end)
    end)
    |> Enum.uniq()
    |> Enum.max_by(&Enum.count(&1))
  end
end
