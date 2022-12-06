import AOC
# import Structure

alias Structure.Stack

aoc 2022, 5 do
  def p1 do
    input = input_path()
    |> File.stream!()

    stacks = input
    |> get_stacks()

    # stacks
    input
    |> Stream.drop_while(fn line -> line != "\n" end)
    |> Stream.drop(1)
    |> Enum.reduce(stacks, fn (line, acc) ->
      line
      |> String.trim()
      |> String.split(" ")
      |> perform_op1(acc)
    end)
  end

  def p2 do
    input = input_path()
    |> File.stream!()

    stacks = input
    |> get_stacks()

    # stacks
    input
    |> Stream.drop_while(fn line -> line != "\n" end)
    |> Stream.drop(1)
    |> Enum.reduce(stacks, fn (line, acc) ->
      line
      |> String.trim()
      |> String.split(" ")
      |> perform_op2(acc)
    end)
  end

  defp perform_op2([_, move, _, from, _, to], stacks ) do
    count = String.to_integer(move)
    # IO.inspect(count)
    # get items
    {stacks, items} = Enum.reduce(1..count, {stacks, []}, fn _, {acc, items} ->
      # IO.inspect(acc)
      {:ok, item} = Stack.head(acc[from])
      # IO.puts(item)
      {:ok, new_from} = Stack.pop(acc[from])
      acc = Map.replace(acc, from, new_from)
      # IO.inspect(acc)
      # IO.puts(to)
      # new_to = Stack.push(acc[to], item)
      # Map.replace(acc, to, new_to)
      {acc, [item | items]}
    end)

    items
    |> Enum.reduce(stacks, fn item, acc ->
      new_to = Stack.push(acc[to], item)
      Map.replace(acc, to, new_to)
    end)
  end

  defp perform_op1([_, move, _, from, _, to], stacks ) do
    count = String.to_integer(move)
    # IO.inspect(count)
    Enum.reduce(1..count, stacks, fn _, acc ->
      # IO.inspect(acc)
      {:ok, item} = Stack.head(acc[from])
      # IO.puts(item)
      {:ok, new_from} = Stack.pop(acc[from])
      acc = Map.replace(acc, from, new_from)
      # IO.inspect(acc)
      # IO.puts(to)
      new_to = Stack.push(acc[to], item)
      Map.replace(acc, to, new_to)
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
        |> Stack.from_list()
        Map.put(acc, id, stack)
      else
        acc
      end
    end)
  end
end
