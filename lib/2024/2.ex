import AOC

aoc 2024, 2 do
  def p1(input) do
    read_input(input)
    |> Enum.map(&safe/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def p2(input) do
    read_input(input)
    |> Enum.map(fn report ->
      {s, _} = safe(report)

      if s > 0 do
        1
      else
        if report
           |> remove_elements()
           |> Enum.any?(fn partial ->
             case safe(partial) do
               {0, _} -> false
               {1, _} -> true
             end
           end) do
          1
        else
          0
        end
      end
    end)
    |> Enum.sum()
  end

  defp remove_elements(report) do
    Stream.unfold({[], report}, fn
      {_pre, []} ->
        nil

      {pre, [n | post]} ->
        {pre ++ post, {pre ++ [n], post}}
    end)
  end

  defp safe(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce_while({0, nil}, fn
      [a, a], _acc ->
        {:halt, {0, :match}}

      [a, b], _acc when abs(a - b) > 3 ->
        {:halt, {0, :too_great}}

      [a, b], {_, nil} when a - b > 0 ->
        {:cont, {1, 1}}

      [a, b], {_, nil} when a - b < 0 ->
        {:cont, {1, -1}}

      [a, b], {_, 1} when a - b > 0 ->
        {:cont, {1, 1}}

      [a, b], {_, -1} when a - b < 0 ->
        {:cont, {1, -1}}

      _elem, _ ->
        {:halt, {0, :wrong_sign}}
    end)
  end

  defp read_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
