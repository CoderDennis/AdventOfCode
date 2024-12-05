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
        Map.update(map, pre, [post], fn list -> [post | list] end)
      end)

    # IO.inspect(Enum.count(updates))

    # rule_map
    updates
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn update ->
      update
      |> String.split(",")
    end)
    |> Enum.filter(fn update ->
      update
      |> Enum.chunk_every(2, 1, :discard)
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

  defp valid_update([[pre, post] | rest], rule_map) do
    if not search_pair(pre, post, rule_map) do
      false
    else
      valid_update(rest, rule_map)
    end
  end

  defp search_pair(pre, post, rule_map) do
    if not Map.has_key?(rule_map, pre) do
      false
    else
      if Enum.member?(Map.get(rule_map, pre), post) do
        true
      else
        Map.get(rule_map, pre)
        |> Enum.any?(&search_pair(&1, post, rule_map))
      end
    end
  end

  def p2(_input) do
  end
end
