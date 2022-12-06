import AOC

aoc 2022, 6 do
  def p1 do
    input_string()
    |> find_unique_chunk(4)
  end

  def p2 do
    input_string()
    |> find_unique_chunk(14)
  end

  defp find_unique_chunk(str, size) do
    (str
    |> String.codepoints()
    |> Enum.chunk_every(size, 1, :discard)
    |> Enum.take_while(fn list -> (MapSet.new(list) |> MapSet.size) != size end)
    |> Enum.count()) + size
  end

end
