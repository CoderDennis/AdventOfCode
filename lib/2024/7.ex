import AOC

aoc 2024, 7 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn eq -> eval_equation(eq, [&(&1 + &2), &(&1 * &2)]) end)
    |> Enum.sum()

    # {test_value, numbers}
  end

  defp eval_equation(equation, ops) do
    [test, values] = String.split(equation, ":")

    [first_value | rest] =
      values
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    eval_equation(String.to_integer(test), first_value, rest, ops)
  end

  defp eval_equation(test_value, test_value, [], _), do: test_value

  defp eval_equation(_test_value, _other_total, [], _), do: 0

  defp eval_equation(test_value, total, _, _) when total > test_value, do: 0

  defp eval_equation(test_value, total, [value | rest], ops) do
    if ops
       |> Enum.map(fn op ->
         eval_equation(test_value, op.(total, value), rest, ops)
       end)
       |> Enum.any?(fn x -> x == test_value end) do
      test_value
    else
      0
    end
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn eq -> eval_equation(eq, [&(&1 + &2), &(&1 * &2), &concat(&1, &2)]) end)
    |> Enum.sum()
  end

  defp concat(a, b) do
    "#{a}#{b}" |> String.to_integer()
  end
end
