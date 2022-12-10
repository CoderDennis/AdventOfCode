import AOC

aoc 2022, 10 do
  def p1 do
    cycles =
      get_cycles()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {x, index}, map ->
        Map.put(map, index + 1, x)
      end)

    [20, 60, 100, 140, 180, 220]
    |> Enum.map(fn cycle -> cycle * IO.inspect(cycles[cycle]) end)
    |> Enum.sum()
  end

  def p2 do
    get_cycles()
    |> Enum.chunk_every(40)
    |> Enum.map(fn row ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {x, index} ->
        if x - 1 <= index and index <= x + 1, do: "#", else: "."
      end)
      |> Enum.join()
    end)
    |> Enum.map(&IO.puts/1)
  end

  def get_cycles() do
    input_stream()
    |> Enum.reduce([1], fn line, [x | _] = acc ->
      case line do
        "noop" -> [x | acc]
        "addx " <> value -> [x + String.to_integer(value) | [x | acc]]
      end
    end)
    |> Enum.reverse()
  end
end
