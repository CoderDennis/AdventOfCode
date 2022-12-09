import AOC

aoc 2022, 9 do
  def p1 do
    get_head_positions()
    |> get_tail_positions()
    |> MapSet.new()
    |> MapSet.size()
  end

  def p2 do # 2488 was too high
    1..9
    |> Enum.reduce(get_head_positions(), fn _, acc ->
      acc
      |> get_tail_positions()
    end)
    |> MapSet.new()
    |> MapSet.size()
    # |> Enum.each(&IO.inspect/1)
  end

  def get_head_positions() do
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
        [cond do
          abs(head_r - tail_r) > 1 -> if tail_r < head_r, do: {tail_r + 1, head_c}, else: {tail_r - 1, head_c}
          abs(head_c - tail_c) > 1 -> if tail_c < head_c, do: {head_r, tail_c + 1}, else: {head_r, tail_c - 1}
          true -> {tail_r, tail_c}
        end | path]
    end)
    |> Enum.reverse()
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
