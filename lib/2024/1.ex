import AOC

aoc 2024, 1 do
  def p1(input) do
    {left, right} =
      input
      |> String.split("\n")
      |> Enum.reduce({[], []}, fn line, {acc1, acc2} ->
        [a, b] =
          line
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        {[a | acc1], [b | acc2]}
      end)

    Enum.sort(left)
    |> Enum.zip(Enum.sort(right))
    |> IO.inspect()
    |> Enum.reduce(0, fn {l, r}, ans ->
      ans + r - l
    end)
  end

  def p2(_input) do
  end
end
