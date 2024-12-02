import AOC

aoc 2024, 1 do
  def p1(input) do
    {left, right} = get_lists(input)

    Enum.sort(left)
    |> Enum.zip(Enum.sort(right))
    |> Enum.reduce(0, fn {l, r}, ans ->
      ans + abs(r - l)
    end)
  end

  def p2(input) do
    {left, right} = get_lists(input)

    right_counts =
      Enum.reduce(right, %{}, fn x, counts ->
        Map.update(counts, x, 1, fn count -> count + 1 end)
      end)

    left
    |> Enum.reduce(0, fn x, ans ->
      ans + x * Map.get(right_counts, x, 0)
    end)
  end

  defp get_lists(input) do
    input
    |> String.split("\n")
    |> Enum.reduce({[], []}, fn line, {acc1, acc2} ->
      [a, b] =
        line
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {[a | acc1], [b | acc2]}
    end)
  end
end
