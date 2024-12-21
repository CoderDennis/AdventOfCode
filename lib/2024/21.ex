import AOC

aoc 2024, 21 do
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

    IO.inspect(path_to_button(directional_keypad, {0, 2}, "<"))

    # step_1 = path_to_code(numeric_keypad, Enum.at(codes, 0))

    # step_2 = path_to_code(directional_keypad, step_1)

    # step_3 = path_to_code(directional_keypad, step_2)

    # step_3
    # |> Enum.join()
    # |> IO.inspect()

    # # v<A<AA>^>AvA^<Av>A^Av<<A>^>AvA^Av<<A>^>AAv<A>A^A<A>Av<A<A>^>AAA<Av>A^A
    # # <vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A

    # step_2
    # |> Enum.join()
    # |> IO.inspect()

    # # v<<A>^>A<A>A<AAv>A^Av<AAA^>A
    # # v<<A>>^A<A>AvA<^AA>A<vAAA>^A
    # step_1
    # |> Enum.join()
    # |> IO.inspect()

    codes
    |> Enum.map(fn code ->
      number =
        code
        |> Enum.take(3)
        |> Enum.map(&String.to_integer/1)
        |> Integer.undigits()

      length =
        path_to_code(numeric_keypad, code)
        |> then(&path_to_code(directional_keypad, &1))
        |> then(&path_to_code(directional_keypad, &1))
        |> Enum.join()
        |> IO.inspect()
        |> String.length()

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
    |> Enum.reduce({a_position, []}, fn button, {current_position, path} ->
      {new_position, button_path} = path_to_button(keypad, current_position, button)
      {new_position, path ++ button_path}
    end)
    |> elem(1)
  end

  @directions [{{-1, 0}, "^"}, {{1, 0}, "v"}, {{0, -1}, "<"}, {{0, 1}, ">"}]

  def path_to_button(keypad, start_position, button) do
    q = :queue.new()

    visited = MapSet.new([start_position])

    q = :queue.in({start_position, []}, q)

    Stream.unfold({q, visited}, fn {q, visited} ->
      case :queue.out(q) do
        {:empty, _q} ->
          nil

        {{:value, {{x, y} = position, path}}, q} ->
          if Map.get(keypad, position) == button do
            {{position, Enum.reverse(["A" | path])}, {q, visited}}
          else
            {q, visited} =
              @directions
              |> Enum.map(fn {{dx, dy}, label} ->
                {{x + dx, y + dy}, label}
              end)
              |> Enum.reject(fn {next, _label} ->
                MapSet.member?(visited, next) or Map.get(keypad, next) == nil
              end)
              |> Enum.reduce({q, visited}, fn {next, label}, {q, visited} ->
                visited = MapSet.put(visited, next)
                q = :queue.in({next, [label | path]}, q)
                {q, visited}
              end)

            {nil, {q, visited}}
          end
      end
    end)
    |> Enum.reject(&(&1 == nil))
    # |> Enum.to_list()
    # |> IO.inspect()
    |> Enum.at(0)
  end

  def p2(_input) do
  end
end
