import AOC

aoc 2022, 7 do
  use Memoize

  def p1(input) do
    fs = get_fs_map(input)

    fs
    |> Map.keys()
    |> Enum.map(fn dir -> get_dir_size(fs, dir) end)
    |> Enum.filter(fn size -> size <= 100_000 end)
    |> Enum.sum()
  end

  def p2(input) do
    fs = get_fs_map(input)

    unused_space = 70_000_000 - get_dir_size(fs, "/")
    needed_space = 30_000_000 - unused_space
    # {unused_space, needed_space}

    fs
    |> Map.keys()
    |> Enum.map(fn dir -> get_dir_size(fs, dir) end)
    |> Enum.filter(fn size -> size >= needed_space end)
    |> Enum.min()
  end

  defp get_fs_map(input) do
    {fs, _} =
      input
      |> String.split("\n")
      |> Stream.map(&String.split/1)
      |> Enum.reduce({%{"/" => %{dirs: [], files: []}}, ["/"]}, fn line,
                                                                   {fs, path = [_ | rest_of_path]} ->
        # IO.inspect(line)
        current = full_dir_name(path)

        case line do
          ["$", "ls"] ->
            {fs, path}

          ["$", "cd", "/"] ->
            {fs, path}

          ["$", "cd", ".."] ->
            {fs, rest_of_path}

          ["$", "cd", d] ->
            path = [d | path]
            d = full_dir_name(path)

            if !Map.has_key?(fs, d) do
              {Map.put(fs, d, %{dirs: [], files: []}), path}
            else
              {fs, path}
            end

          ["dir", d] ->
            dir_name = [d | path] |> full_dir_name()

            {Map.replace!(
               fs,
               current,
               Map.replace!(fs[current], :dirs, [dir_name | fs[current][:dirs]])
             ), path}

          [size, filename] ->
            {Map.replace!(
               fs,
               current,
               Map.replace!(fs[current], :files, [
                 %{name: filename, size: String.to_integer(size)} | fs[current][:files]
               ])
             ), path}
        end
      end)

    fs
  end

  defmemo get_dir_size(fs, dir) do
    # IO.inspect(dir)
    filesize =
      fs[dir][:files]
      |> Enum.reduce(0, fn %{size: size}, acc -> acc + size end)

    dirsize =
      fs[dir][:dirs]
      |> Enum.reduce(0, fn dir, acc -> acc + get_dir_size(fs, dir) end)

    filesize + dirsize
  end

  defp full_dir_name(path) do
    path
    |> Enum.reverse()
    |> Enum.join("/")
  end
end
