import AOC

aoc 2024, 21 do
  use Memoize

  alias Helpers.CoordinateMap

  def p1(input) do
    codes =
      input
      |> String.split("\n")
      |> Enum.map(&String.codepoints/1)

    numeric_keypad =
      [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], [nil, "0", "A"]]
      |> CoordinateMap.create_from_lists()

    directional_keypad =
      [[nil, "^", "A"], ["<", "v", ">"]]
      |> CoordinateMap.create_from_lists()

    # IO.inspect({numeric_keypad, directional_keypad})

    # IO.inspect(paths_to_button(directional_keypad, {0, 2}, "<"))

    codes
    |> Stream.map(fn code ->
      number =
        code
        |> Enum.take(3)
        |> Enum.map(&String.to_integer/1)
        |> Integer.undigits()

      length =
        path_to_code(numeric_keypad, code)
        |> elem(1)
        # |> IO.inspect()
        |> Enum.flat_map(fn code ->
          path_to_code(directional_keypad, code)
          |> elem(1)
        end)
        |> Enum.flat_map(fn code ->
          path_to_code(directional_keypad, code)
          |> elem(1)
        end)
        # |> IO.inspect()
        |> Enum.map(&Enum.count/1)
        |> Enum.min()

      IO.inspect({length, number})
      number * length
    end)
    |> Enum.sum()
  end

  def path_to_code(keypad, code) do
    {a_position, _} =
      keypad
      |> Enum.find(&(elem(&1, 1) == "A"))

    code
    |> Enum.reduce({a_position, [[]]}, fn button, {start_position, paths} ->
      {next_position, button_paths} = shortest_paths_to_button(keypad, start_position, button)

      shortest_paths =
        button_paths
        |> Enum.flat_map(fn button_path ->
          paths
          |> Enum.map(fn path ->
            Enum.concat(path, button_path)
          end)
        end)
        |> keep_shortest_paths()

      {next_position, shortest_paths}
    end)
  end

  @directions [{{-1, 0}, "^"}, {{1, 0}, "v"}, {{0, -1}, "<"}, {{0, 1}, ">"}]

  defmemo shortest_paths_to_button(keypad, start_position, button) do
    q = :queue.new()
    q = :queue.in({start_position, [], MapSet.new([start_position])}, q)

    # can we keep track of the length of the path along the way so we don't need to count the path length later?

    button_paths =
      Stream.unfold(q, fn q ->
        case :queue.out(q) do
          {:empty, _q} ->
            nil

          {{:value, {{x, y} = position, path, visited}}, q} ->
            if Map.get(keypad, position) == button do
              {{position, Enum.reverse(["A" | path])}, q}
            else
              q =
                @directions
                |> Enum.map(fn {{dx, dy}, label} ->
                  {{x + dx, y + dy}, label}
                end)
                |> Enum.reject(fn {next, _label} ->
                  MapSet.member?(visited, next) or Map.get(keypad, next) == nil
                end)
                |> Enum.reduce(q, fn {next, label}, q ->
                  visited = MapSet.put(visited, next)
                  :queue.in({next, [label | path], visited}, q)
                end)

              {nil, q}
            end
        end
      end)
      |> Enum.reject(&(&1 == nil))
      |> Enum.uniq()

    {button_position, _} = Enum.at(button_paths, 0)

    shortest_paths =
      button_paths
      |> Enum.map(&elem(&1, 1))
      |> keep_shortest_paths()

    {button_position, shortest_paths}
  end

  def p2(_input) do
    # codes =
    #   input
    #   |> String.split("\n")
    #   |> Enum.map(&String.codepoints/1)

    # numeric_keypad =
    #   [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], [nil, "0", "A"]]
    #   |> CoordinateMap.create_from_lists()

    # directional_keypad =
    #   [[nil, "^", "A"], ["<", "v", ">"]]
    #   |> CoordinateMap.create_from_lists()

    # possible approach:
    # find the path for each button one at a time all the way down in such a way that we can memoize the result at each step
    # doesn't seem to work because each robot only resets at the begining of each sequence.

    # codes
    # |> Stream.map(fn code ->
    #   number =
    #     code
    #     |> Enum.take(3)
    #     |> Enum.map(&String.to_integer/1)
    #     |> Integer.undigits()

    #   length =
    #     path_to_code_2(numeric_keypad, directional_keypad, code, 2)
    #     |> elem(1)
    #     |> Enum.map(&Enum.count/1)
    #     |> Enum.min()

    #   IO.inspect({length, number})
    #   number * length
    # end)
    # |> Enum.sum()
  end

  def keep_shortest_paths(paths) do
    {length_map, shortest_length} =
      paths
      |> Enum.map(&{Enum.count(&1), &1})
      |> Enum.reduce({%{}, :infinity}, fn {len, path}, {map, shortest_length} ->
        {Map.update(map, len, [path], fn paths -> [path | paths] end), min(shortest_length, len)}
      end)

    Map.get(length_map, shortest_length)
  end
end
