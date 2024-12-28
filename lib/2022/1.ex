import AOC

aoc 2022, 1 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.reduce({0, 0}, fn line, {ans, current} ->
      if line == "" do
        {max(ans, current), 0}
      else
        {ans, current + String.to_integer(line)}
      end
    end)
    |> elem(0)
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.reduce([0], fn line, totals ->
      if line == "" do
        [0 | totals]
      else
        [current | rest] = totals
        [current + String.to_integer(line) | rest]
      end
    end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
