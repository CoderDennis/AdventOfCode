import AOC

aoc 2024, 5 do
  def p1(input) do
    {rules, updates} =
      input
      |> String.split("\n")
      |> Enum.split_while(fn x -> x != "" end)

    rule_map =
      rules
      |> Enum.reduce(%{}, fn rule, map ->
        [pre, post] = String.split(rule, "|")
        Map.update(map, pre, MapSet.new([post]), fn set -> MapSet.put(set, post) end)
      end)

    # rule_map
    updates
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn update ->
      update
      |> String.split(",")
    end)
    |> Enum.filter(fn update ->
      update
      |> valid_update(rule_map)
    end)
    |> Enum.map(fn update ->
      mid =
        update
        |> Enum.count()
        |> div(2)

      update
      |> Enum.at(mid)
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  defp valid_update([], _), do: true

  defp valid_update([page | rest], rule_map) do
    if Enum.any?(rest, fn following_page ->
         MapSet.member?(Map.get(rule_map, following_page, MapSet.new()), page)
       end) do
      false
    else
      valid_update(rest, rule_map)
    end
  end

  def p2(input) do
    {rules, updates} =
      input
      |> String.split("\n")
      |> Enum.split_while(fn x -> x != "" end)

    rule_map =
      rules
      |> Enum.reduce(%{}, fn rule, map ->
        [pre, post] = String.split(rule, "|")
        Map.update(map, pre, MapSet.new([post]), fn set -> MapSet.put(set, post) end)
      end)

    # rule_map
    updates
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn update ->
      update
      |> String.split(",")
    end)
    |> Enum.reject(fn update ->
      update
      |> valid_update(rule_map)
    end)
    |> Enum.map(&sort_update(&1, rule_map))
    |> Enum.map(fn update ->
      mid =
        update
        |> Enum.count()
        |> div(2)

      update
      |> Enum.at(mid)
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  defp sort_update(update, rule_map) do
    Enum.sort(update, fn a, b -> MapSet.member?(Map.get(rule_map, a, MapSet.new()), b) end)
  end
end
