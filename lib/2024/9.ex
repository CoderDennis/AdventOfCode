import AOC

aoc 2024, 9 do
  def p1(input) do
    disk =
      input
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2, 2, [0])
      |> Enum.with_index()
      |> map_to_disk()

    end_index = Enum.count(disk) - 1

    compact(disk, [], 0, end_index, Enum.reverse(disk))
    |> checksum()
  end

  def map_to_disk([]), do: []

  def map_to_disk([{[file_size, free_space], file_id} | rest]) do
    [
      repeat(file_id, file_size),
      repeat(".", free_space),
      map_to_disk(rest)
    ]
    |> Enum.concat()
  end

  defp repeat(elem, count) do
    Stream.repeatedly(fn -> elem end)
    |> Enum.take(count)
  end

  def compact(_disk, compacted, index, end_index, _end_of_disk) when index > end_index,
    do: Enum.reverse(compacted)

  def compact(disk, compacted, index, end_index, ["." | end_of_disk]) do
    compact(disk, compacted, index, end_index - 1, end_of_disk)
  end

  def compact(["." | rest_of_disk], compacted, index, end_index, [file_id | end_of_disk]) do
    compact(rest_of_disk, [file_id | compacted], index + 1, end_index - 1, end_of_disk)
  end

  def compact([file_id | rest_of_disk], compacted, index, end_index, end_of_disk) do
    compact(rest_of_disk, [file_id | compacted], index + 1, end_index, end_of_disk)
  end

  def checksum(disk) do
    disk
    |> Enum.with_index()
    |> Enum.reduce(0, fn
      {".", _}, sum -> sum
      {file_id, block_position}, sum -> file_id * block_position + sum
    end)
  end

  def p2(input) do
    disk =
      input
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2, 2, [0])
      |> Enum.with_index()
      |> map_to_disk2([])
      |> Enum.with_index()

    defrag(disk, Enum.reverse(disk))
    |> defraged_to_disk()
    |> checksum()
  end

  def map_to_disk2([], disk), do: Enum.reverse(disk)

  def map_to_disk2([{[file_size, free_space], file_id} | rest], disk) do
    map_to_disk2(rest, [{".", free_space}, {file_id, file_size} | disk])
  end

  def defrag(disk, []), do: disk

  def defrag(disk, [{{".", _}, _} | end_of_disk]) do
    defrag(disk, end_of_disk)
  end

  def defrag(disk, [{{file_id, file_size}, end_index} | end_of_disk]) do
    case disk
         |> Enum.with_index()
         |> Enum.find(disk, fn
           {{{".", space}, index}, _} when space >= file_size and index < end_index ->
             true

           _ ->
             false
         end) do
      {{{".", space}, index}, current_index} ->
        {pre, [_ | post]} = Enum.split(disk, current_index)

        # replace file_id in post with free space
        post =
          post
          |> Enum.map(fn
            {{^file_id, space}, index} -> {{".", space}, index}
            other -> other
          end)

        [pre, [{{file_id, file_size}, index}, {{".", space - file_size}, index}], post]
        |> Enum.concat()
        |> defrag(end_of_disk)

      _ ->
        defrag(disk, end_of_disk)
    end
  end

  def defraged_to_disk([]), do: []

  def defraged_to_disk([{{file_id, size}, _} | rest]) do
    [
      repeat(file_id, size),
      defraged_to_disk(rest)
    ]
    |> Enum.concat()
  end
end
