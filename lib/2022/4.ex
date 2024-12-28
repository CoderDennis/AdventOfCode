import AOC

aoc 2022, 4 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&is_fully_contained/1)
    |> Enum.count()
  end

  defp is_fully_contained(pair) do
    [[e1_1, e1_2], [e2_1, e2_2]] =
      pair
      |> String.split(",")
      |> Enum.map(&numbers/1)

    (e1_1 <= e2_1 and e1_2 >= e2_2) or (e2_1 <= e1_1 and e2_2 >= e1_2)
  end

  defp is_contained(pair) do
    [[e1_1, e1_2], [e2_1, e2_2]] =
      pair
      |> String.split(",")
      |> Enum.map(&numbers/1)

    (e1_1 <= e2_2 and e1_2 >= e2_1) or (e2_1 <= e1_2 and e2_2 >= e1_1)
  end

  defp numbers(s) do
    s
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&is_contained/1)
    |> Enum.count()
  end
end
