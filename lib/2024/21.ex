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

    # {directional_a_position, _} =
    #   directional_keypad
    #   |> Enum.find(&(elem(&1, 1) == "A"))

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

      {next_position, shortest_paths}
    end)
  end

  @directions [{{-1, 0}, "^"}, {{1, 0}, "v"}, {{0, -1}, "<"}, {{0, 1}, ">"}]

  defmemo shortest_paths_to_button(keypad, start_position, button) do
    q = :queue.new()
    q = :queue.in({start_position, [], MapSet.new([start_position])}, q)

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

    paths_with_lenghts =
      button_paths
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(fn path ->
        {path, Enum.count(path)}
      end)

    shortest_path_length =
      paths_with_lenghts
      |> Enum.map(&elem(&1, 1))
      |> Enum.min()

    shortest_paths =
      paths_with_lenghts
      |> Enum.filter(fn {_, len} -> len == shortest_path_length end)
      |> Enum.map(&elem(&1, 0))

    {button_position, shortest_paths}
  end

  def p2(input) do
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

    # possible approach:
    # find the path for each button one at a time all the way down in such a way that we can memoize the result at each step
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

    shortest_paths_to_button_2(directional_keypad, {0, 2}, "<", 3)
  end

  def path_to_code_2(numeric_keypad, directional_keypad, code, robot_count) do
    {numeric_a_position, _} =
      numeric_keypad
      |> Enum.find(&(elem(&1, 1) == "A"))

    {directional_a_position, _} =
      directional_keypad
      |> Enum.find(&(elem(&1, 1) == "A"))

    code
    |> Enum.reduce({numeric_a_position, [[]]}, fn button, {start_position, paths} ->
      {next_position, button_paths} =
        shortest_paths_to_button(numeric_keypad, start_position, button)

      shortest_paths =
        button_paths
        |> Enum.flat_map(fn button_path ->
          paths
          |> Enum.map(fn path ->
            Enum.concat(path, button_path)
          end)
        end)

      shortest_paths =
        shortest_paths
        |> Enum.map(fn path ->
          path
          |> Enum.reduce({directional_a_position, [[]]}, fn button, {start_position, paths} ->
            {next_position, button_paths} =
              shortest_paths_to_button_2(
                directional_keypad,
                start_position,
                button,
                robot_count
              )

            shortest_paths =
              button_paths
              |> Enum.flat_map(fn button_path ->
                paths
                |> Enum.map(fn path ->
                  Enum.concat(path, button_path)
                end)
              end)

            {next_position, shortest_paths}
          end)
        end)
        |> Enum.map(&elem(&1, 1))

      {next_position, shortest_paths}
    end)
  end

  def shortest_paths_to_button_2(keypad, start_position, button, 0) do
    # shortest_paths_to_button(keypad, start_position, button)
    [{{-1, -1}, []}]
  end

  def shortest_paths_to_button_2(keypad, start_position, button, robot_count) do
    IO.inspect({start_position, button, robot_count})
    q = :queue.new()
    q = :queue.in({start_position, [], MapSet.new([start_position])}, q)

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
      |> IO.inspect(label: "button_paths")

    {button_position, _} =
      Enum.at(button_paths, 0)

    paths_with_lenghts =
      button_paths
      |> Enum.map(&elem(&1, 1))
      |> Enum.map(fn path ->
        {path, Enum.count(path)}
      end)

    # |> IO.inspect()

    shortest_path_length =
      paths_with_lenghts
      |> Enum.map(&elem(&1, 1))
      |> Enum.min()

    shortest_paths =
      paths_with_lenghts
      |> Enum.filter(fn {_, len} -> len == shortest_path_length end)
      |> Enum.map(&elem(&1, 0))

    shortest_paths =
      shortest_paths
      |> IO.inspect(label: "shortest_paths")
      |> Enum.flat_map(fn path ->
        path
        |> Enum.reduce({button_position, [[]]}, fn button, {start_position, paths} ->
          IO.inspect({button, start_position, paths})

          {next_position, button_paths} =
            shortest_paths_to_button_2(keypad, start_position, button, robot_count - 1)
            |> IO.inspect(label: "recursive call")

          shortest_paths =
            button_paths
            |> Enum.flat_map(fn button_path ->
              paths
              |> Enum.map(fn path ->
                Enum.concat(path, button_path)
              end)
            end)

          {next_position, shortest_paths}
        end)
      end)
      |> Enum.map(&elem(&1, 1))

    {button_position, shortest_paths}
    |> IO.inspect(label: "{button_position, shortest_paths}")
  end
end
