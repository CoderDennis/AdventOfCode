import AOC

aoc 2022, 9 do
  def p1 do
    get_head_positions()
    |> get_tail_positions()
    |> MapSet.new()
    |> MapSet.size()
  end

  def p2 do
    1..9
    |> Enum.reduce(get_head_positions(), fn _, acc ->
      acc
      |> get_tail_positions()
    end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def visualize_part2 do
    1..9
    |> Enum.reduce([get_head_positions()], fn _, acc = [head | _] ->
      [(head |> get_tail_positions()) | acc]
    end)
    |> Enum.reverse()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&draw/1)
    |> Enum.each(fn x ->
      IO.puts(x)
      IO.puts("\n")
    end)
  end

  def draw(rope) do
    positions = rope
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn {position, index}, map ->
      map
      |> Map.put(position, index)
    end)
    4..0
    |> Enum.map(fn r ->
      0..5
      |> Enum.map(fn c ->
        if Map.has_key?(positions, {r,c}) do
          if positions[{r,c}] == 0, do: "H", else: positions[{r,c}]
        else
          "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  def get_head_positions do
    start = {0,0}

    input_stream()
    |> Stream.map(&String.split/1)
    |> Enum.reduce([start], fn [direction, count], path ->
      {r, c} = case direction do
        "R" -> {0,1}
        "L" -> {0,-1}
        "U" -> {1,0}
        "D" -> {-1,0}
      end

      count = String.to_integer(count)
      1..count
      |> Enum.reduce(path, fn _, acc = [{head_r, head_c} | _] ->
        [{head_r + r, head_c + c} | acc]
      end)
    end)
    |> Enum.reverse()
  end

  def get_tail_positions(head_positions) do
    start = {0,0}

    head_positions
    |> Enum.reduce([start], fn {head_r, head_c}, path = [{tail_r, tail_c} | _] ->
        [(cond do
          abs(head_r - tail_r) > 1 and abs(head_c - tail_c) > 1 ->
            {
              (if tail_r < head_r, do: tail_r + 1, else: tail_r - 1),
              (if tail_c < head_c, do: tail_c + 1, else: tail_c - 1)
            }
          abs(head_r - tail_r) > 1 -> if tail_r < head_r, do: {tail_r + 1, head_c}, else: {tail_r - 1, head_c}
          abs(head_c - tail_c) > 1 -> if tail_c < head_c, do: {head_r, tail_c + 1}, else: {head_r, tail_c - 1}
          true -> {tail_r, tail_c}
        end) | path]
    end)
    |> Enum.reverse()
    |> Enum.drop(1)
  end

  def get_tail_positions() do
    start = {0,0}

    input_stream()
    |> Stream.map(&String.split/1)
    |> Enum.reduce({start, [start]}, fn [direction, count], {head, path} ->
      {r, c} = case direction do
        "R" -> {0,1}
        "L" -> {0,-1}
        "U" -> {1,0}
        "D" -> {-1,0}
      end
      count = String.to_integer(count)
      1..count
      |> Enum.reduce({head, path}, fn _, {{head_r, head_c}, path = [{tail_r, tail_c} | _]} ->
        head_r = head_r + r
        head_c = head_c + c
        tail = cond do
          abs(head_r - tail_r) > 1 -> if tail_r < head_r, do: {tail_r + 1, head_c}, else: {tail_r - 1, head_c}
          abs(head_c - tail_c) > 1 -> if tail_c < head_c, do: {head_r, tail_c + 1}, else: {head_r, tail_c - 1}
          true -> {tail_r, tail_c}
        end
        {{head_r, head_c}, [tail | path]}
      end)
    end)
    |> elem(1)
  end

end
