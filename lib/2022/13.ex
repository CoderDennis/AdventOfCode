import AOC

aoc 2022, 13 do
  # 255, 295, 592 are too low
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(fn x -> elem(x, 0) end)
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.map(fn {[left, right], index} ->
      if compare(left, right) == :gt, do: 0, else: index
    end)
    |> Enum.sum()
  end

  def compare([], []), do: :eq
  def compare([], _), do: :lt

  def compare([left_hd | left_rest], [right_hd | right_rest])
      when is_integer(left_hd) and is_integer(right_hd) do
    cond do
      left_hd < right_hd -> :lt
      left_hd > right_hd -> :gt
      true -> compare(left_rest, right_rest)
    end
  end

  def compare([left_hd | left_rest], [right_hd | right_rest]) do
    case compare(left_hd, right_hd) do
      :eq -> compare(left_rest, right_rest)
      result -> result
    end
  end

  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :lt
      left > right -> :gt
      true -> :eq
    end
  end

  def compare(left, right) when is_integer(left), do: compare([left], right)

  def compare(left, right) when is_integer(right), do: compare(left, [right])

  def compare(_, _), do: :gt

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(fn x -> elem(x, 0) end)
    |> Enum.concat([[[2]], [[6]]])
    |> Enum.sort(__MODULE__)
    |> Enum.with_index(1)
    |> Enum.reduce(1, fn {packet, index}, acc ->
      if packet == [[2]] or packet == [[6]] do
        acc * index
      else
        acc
      end
    end)
  end
end
