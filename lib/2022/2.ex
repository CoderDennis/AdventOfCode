import AOC

aoc 2022, 2 do
  def p1 do
    input_stream(2022, 2)
    |> Enum.map(fn line -> score1(String.codepoints(line)) end)
    |> Enum.sum()
  end

  def p2 do
    input_stream(2022, 2)
    |> Enum.map(fn line -> score2(String.codepoints(line)) end)
    |> Enum.sum()
  end

  defp score2([them, " ", result]) do
    case {them, result} do
      {"A", "X"} -> 3
      {"B", "X"} -> 1
      {"C", "X"} -> 2

      {"A", "Y"} -> 4
      {"B", "Y"} -> 5
      {"C", "Y"} -> 6

      {"A", "Z"} -> 8
      {"B", "Z"} -> 9
      {"C", "Z"} -> 7
    end
  end

  defp score1([them, " ", you]) do
    game = case {them, you} do
      {"A", "X"} -> 3
      {"B", "Y"} -> 3
      {"C", "Z"} -> 3
      {"A", "Y"} -> 6
      {"B", "Z"} -> 6
      {"C", "X"} -> 6
      _ -> 0
    end
    game + case you do
      "X" -> 1
      "Y" -> 2
      "Z" -> 3
    end
  end
end
