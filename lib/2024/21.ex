import AOC

aoc 2024, 21 do
  use Memoize

  alias Helpers.CoordinateMap

  def p1(input) do
    solution(input, 2)
  end

  def p2(input) do
    solution(input, 25)
  end

  def solution(input, robot_count) do
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

    # approach thoughts:
    # find the path for each button one at a time all the way down in such a way that we can memoize the result at each step
    # each robot only resets at the begining of each sequence, but they always need to direct the keypad to the A.

    # Sequence has to be found one button at a time. It’s more like DFS than BFS.
    # At each button, dfs down to last layer and return the count there. Exploring all the available shortest paths.
    # Keep track of location at the end of each lower layer.

    # Between each layer, look up paths to button keeping track of last position.

    codes
    |> Stream.map(fn code ->
      number =
        code
        |> Enum.take(3)
        |> Enum.map(&String.to_integer/1)
        |> Integer.undigits()

      {number, path_to_code(numeric_keypad, code)}
    end)
    |> Enum.map(fn {number, paths} ->
      {number,
       paths
       |> Enum.map(fn path ->
         path
         |> Enum.reduce({keypad_a_position(directional_keypad), 0}, fn btn, {position, sum} ->
           {next_path_position, count} =
             sequence_count_for_button(directional_keypad, position, btn, robot_count)

           {next_path_position, sum + count}
         end)
       end)
       |> Enum.map(&elem(&1, 1))
       |> Enum.min()}
      |> IO.inspect()
    end)
    |> Enum.map(fn {n, l} -> n * l end)
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

      {next_position, shortest_paths}
    end)
    |> elem(1)
    |> keep_shortest_paths()
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

  defmemo sequence_count_for_button(_keypad, _start_position, _button, 0) do
    {nil, 1}
  end

  defmemo sequence_count_for_button(keypad, start_position, button, robot_count) do
    a_position = keypad_a_position(keypad)

    {next_position, shortest_paths} =
      shortest_paths_to_button(keypad, start_position, button)

    length =
      shortest_paths
      |> Enum.map(fn path ->
        path
        |> Enum.reduce({a_position, 0}, fn btn, {position, sum} ->
          {next_path_position, count} =
            sequence_count_for_button(keypad, position, btn, robot_count - 1)

          {next_path_position, sum + count}
        end)
      end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.min()

    {next_position, length}
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

  defmemo keypad_a_position(keypad) do
    keypad
    |> Enum.find(&(elem(&1, 1) == "A"))
    |> elem(0)
  end
end
