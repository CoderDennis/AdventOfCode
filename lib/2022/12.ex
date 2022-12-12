import AOC

aoc 2022, 12 do
  def p1 do
    {map, s, e} =
      input_stream()
      |> Enum.map(&String.to_charlist/1)
      |> Enum.with_index()
      |> Enum.reduce({%{}, {0, 0}, {0, 0}}, fn {line, row}, {map, s, e} ->
        line
        |> Enum.with_index()
        |> Enum.reduce({map, s, e}, fn {position, col}, {map_, s_, e_} ->
          {value, s, e} =
            case position do
              ?S ->
                {?a, {row, col}, e_}

              ?E ->
                {?z, s_, {row, col}}

              v ->
                {v, s_, e_}
            end

          {Map.put(map_, {row, col}, value), s, e}
        end)
      end)
      |> IO.inspect()

    # {map, s, e}
    # q = :queue.new()

    # if :ets.whereis(:visited) == :undefined do
    #   :ets.delete(:visited)
    # end

    :ets.new(:visited, [:set, :private, :named_table])
    search([{s, 0}], map, e)
  end

  defp visit(position) do
    :ets.insert(:visited, {position, true})
  end

  defp visited?(position) do
    case :ets.lookup(:visited, position) do
      [{^position, _}] -> true
      [] -> false
    end
  end

  defp search([], _map, _e) do
    :infinity
  end

  defp search([{{row, col}, step_count} | _], _map, {row, col}) do
    step_count
  end

  defp search([{{row, col} = position, step_count} | rest], map, e) do
    # IO.inspect(position)

    if visited?(position) do
      search(rest, map, e)
    else
      visit(position)

      neighbors =
        [
          {-1, 0},
          {1, 0},
          {0, -1},
          {0, 1}
        ]
        |> Enum.map(fn {r_offset, c_offset} ->
          {row + r_offset, col + c_offset}
        end)
        |> Enum.filter(fn p ->
          Map.has_key?(map, p) and not visited?(p) and map[p] - map[position] <= 1
        end)
        |> Enum.map(fn p -> {p, step_count + 1} end)

      search(rest ++ neighbors, map, e)
    end
  end

  def p2 do
    {map, s, e} =
      input_stream()
      |> Enum.map(&String.to_charlist/1)
      |> Enum.with_index()
      |> Enum.reduce({%{}, [], {0, 0}}, fn {line, row}, {map, s, e} ->
        line
        |> Enum.with_index()
        |> Enum.reduce({map, s, e}, fn {position, col}, {map_, s_, e_} ->
          {value, s, e} =
            case position do
              ?S ->
                {?a, [{row, col} | s_], e_}

              ?E ->
                {?z, s_, {row, col}}

              ?a ->
                {?a, [{row, col} | s_], e_}

              v ->
                {v, s_, e_}
            end

          {Map.put(map_, {row, col}, value), s, e}
        end)
      end)

    # |> IO.inspect()

    s
    |> Enum.map(fn s_ ->
      :ets.new(:visited, [:named_table])
      result = search([{s_, 0}], map, e)
      :ets.delete(:visited)
      result
    end)
    |> Enum.min()

    # :ets.new(:visited, [:set, :private, :named_table])
    # search([{s, 0}], map, e)
  end
end
