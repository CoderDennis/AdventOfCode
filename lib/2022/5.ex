import AOC

aoc 2022, 5 do
  def p1 do
    helper(&perform_op1/2)
  end

  def p2 do
    helper(&perform_op2/2)
  end

  defp helper(fun) do
    input = input_path()
    |> File.stream!()

    stacks = input
    |> get_stacks()

    input
    |> Stream.drop_while(fn line -> line != "\n" end)
    |> Stream.drop(1)
    |> Enum.reduce(stacks, fn (line, acc) ->
      line
      |> String.trim()
      |> String.split(" ")
      |> fun.(acc)
    end)
    |> Map.values()
    |> Enum.map(&hd/1)
    |> List.to_string()
  end

  defp perform_op2([_, move, _, from, _, to], stacks ) do
    count = String.to_integer(move)
    {stacks, items} = Enum.reduce(1..count, {stacks, []}, fn _, {acc, items} ->
      [item | new_from] = acc[from]
      acc = Map.replace(acc, from, new_from)
      {acc, [item | items]}
    end)

    items
    |> Enum.reduce(stacks, fn item, acc ->
      Map.replace(acc, to, [item | acc[to]])
    end)
  end

  defp perform_op1([_, move, _, from, _, to], stacks ) do
    count = String.to_integer(move)
    Enum.reduce(1..count, stacks, fn _, acc ->
      [item | new_from] = acc[from]
      acc = Map.replace(acc, from, new_from)
      Map.replace(acc, to, [item | acc[to]])
    end)
  end

  defp get_stacks(input) do
    input
    |> Stream.take_while(fn line -> line != "\n" end)
    |> Enum.map(&String.codepoints/1)
    |> Enum.zip_with(& &1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reduce(%{}, fn ([id | items], acc) ->
      if id >= "1" and id <= "9" do
        stack = items
        |> Enum.take_while(fn i -> i != " " end)
        |> Enum.reverse()
        Map.put(acc, id, stack)
      else
        acc
      end
    end)
  end
end
