import AOC

aoc 2022, 3 do
  def p1 do
    input_stream()
    |> Enum.map(&find_item/1)
    |> Enum.map(&item_priority/1)
    |> Enum.sum()
  end

  defp find_item(line) do
    size = String.length(line) |> div(2)
    item_set = String.codepoints(line)
    |> Enum.take(size)
    |> MapSet.new()

    String.codepoints(line)
    |> Enum.drop(size)
    |> Enum.find(fn item -> MapSet.member?(item_set, item) end)
  end

  defp item_priority(<<item::utf8>>) do
    if item >= ?a && item <= ?z do
      item - ?a + 1
    else
      item - ?A + 27
    end
  end

  def p2 do
    input_stream()
    |> Enum.map(&String.codepoints/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&find_common_item/1)
    |> Enum.map(&item_priority/1)
    |> Enum.sum()
  end

  defp find_common_item(elves) do
    elves
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
    |> hd()
  end
end
