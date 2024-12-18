import AOC

aoc 2024, 18 do
  def p1(input) do
    space_dimension = 70

    byte_count = 1024

    input
    |> parse_input()
    |> Enum.take(byte_count)
    |> find_exit(space_dimension)
  end

  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def find_exit(bytes, space_dimension) do
    bytes = MapSet.new(bytes)

    q = :queue.new()

    visited = MapSet.new([{0, 0}])

    q = :queue.in({{0, 0}, 0}, q)

    Stream.unfold({q, visited}, fn {q, visited} ->
      case :queue.out(q) do
        {:empty, _q} ->
          nil

        {{:value, {{^space_dimension, ^space_dimension}, steps}}, _q} ->
          {steps, {:queue.new(), nil}}

        {{:value, {{x, y}, steps}}, q} ->
          {new_q, new_visited} =
            @directions
            |> Enum.map(fn {dx, dy} ->
              {x + dx, y + dy}
            end)
            |> Enum.filter(fn {x, y} ->
              0 <= x and x <= space_dimension and
                0 <= y and y <= space_dimension
            end)
            |> Enum.reject(fn next ->
              MapSet.member?(visited, next) or MapSet.member?(bytes, next)
            end)
            |> Enum.reduce({q, visited}, fn next, {q, visited} ->
              visited = MapSet.put(visited, next)
              q = :queue.in({next, steps + 1}, q)
              {q, visited}
            end)

          {nil, {new_q, new_visited}}
      end
    end)
    |> Enum.at(-1)
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&List.to_tuple/1)
  end

  def p2(input) do
    space_dimension = 70

    # byte_count = 1024

    input
    |> parse_input()
    |> Enum.reduce_while([], fn byte, bytes ->
      # IO.inspect(byte)
      bytes = [byte | bytes]

      case find_exit(bytes, space_dimension) do
        nil ->
          {:halt, bytes}

        _result ->
          {:cont, bytes}
      end
    end)
    |> Enum.at(0)
  end
end
