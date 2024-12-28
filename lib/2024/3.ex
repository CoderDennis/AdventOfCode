import AOC

aoc 2024, 3 do
  def p1(input) do
    ~r/mul\((\d+),(\d+)\)/
    |> Regex.scan(input)
    |> Enum.map(fn [_, x, y] ->
      String.to_integer(x) * String.to_integer(y)
    end)
    |> Enum.sum()
  end

  def p2(input) do
    ~r/(mul\((\d+),(\d+)\))|(don't\(\))|(do\(\))/
    |> Regex.scan(input)
    |> Enum.reduce({0, true}, fn
      ["don't()" | _], {sum, _} -> {sum, false}
      ["do()" | _], {sum, _} -> {sum, true}
      _, {sum, false} -> {sum, false}
      [_, _, x, y], {sum, true} -> {sum + String.to_integer(x) * String.to_integer(y), true}
    end)
  end
end
