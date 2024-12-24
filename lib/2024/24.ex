import AOC

aoc 2024, 24 do
  def p1(input) do
    {wires, nil_wires, gates} = parse_input(input)

    {:ok, wire_values} = run(wires, nil_wires, gates)

    wire_values
    |> get_number("z")
  end

  def p2(input) do
    {wires, nil_wires, gates} = parse_input(input)

    # optimizaion strategy: look for matching bits with a given swap,
    # then look for another swap that matches more bits

    swap_so_addition_works(wires, nil_wires, gates)
  end

  def swap_so_addition_works(wires, nil_wires, gates) do
    x = get_number(wires, "x")
    y = get_number(wires, "y")

    # expected_z = Bitwise.band(x, y) # used in example

    expected_z = x + y

    IO.inspect(expected_z, label: "expected_z")

    # when swapping gate output wires, we could create loops or configurations that don't terminate
    gate_keys = Map.keys(gates)

    pairs =
      for(x <- gate_keys, y <- gate_keys, x != y, do: [x, y] |> Enum.sort() |> List.to_tuple())
      |> Enum.uniq()

    pairs_to_swap =
      pairs
      |> Stream.flat_map(fn {ax, ay} = a ->
        pairs
        |> Enum.filter(fn {bx, by} ->
          4 == [ax, ay, bx, by] |> MapSet.new() |> MapSet.size()
        end)
        |> Stream.flat_map(fn {bx, by} = b ->
          pairs
          |> Enum.filter(fn {cx, cy} ->
            6 == [ax, ay, bx, by, cx, cy] |> MapSet.new() |> MapSet.size()
          end)
          |> Stream.flat_map(fn {cx, cy} = c ->
            pairs
            |> Enum.filter(fn {dx, dy} ->
              8 == [ax, ay, bx, by, cx, cy, dx, dy] |> MapSet.new() |> MapSet.size()
            end)
            |> Stream.map(fn d ->
              [a, b, c, d]
            end)
          end)
        end)
      end)

    pairs_to_swap
    |> Stream.drop_while(fn pairs ->
      IO.inspect(pairs)

      swapped_gates =
        pairs
        |> Enum.reduce(gates, fn {x, y}, swapped_gates ->
          x_val = Map.get(swapped_gates, x)
          y_val = Map.get(swapped_gates, y)

          swapped_gates
          |> Map.put(x, y_val)
          |> Map.put(y, x_val)
        end)

      # check result
      case run(wires, nil_wires, swapped_gates) do
        {:ok, wire_values} -> get_number(wire_values, "z") != expected_z
        {:error, _} -> true
      end
    end)
    # |> IO.inspect()
    |> Enum.at(0)
  end

  def get_number(wires, starts_with) do
    wires
    |> Enum.filter(fn {wire, _value} -> String.starts_with?(wire, starts_with) end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    # |> IO.inspect()
    |> Enum.map(fn
      {_, true} -> 1
      {_, false} -> 0
    end)
    |> Integer.undigits(2)
  end

  def run(wires, nil_wires, gates) do
    if MapSet.size(nil_wires) == 0 do
      {:ok, wires}
    else
      new_wire_values =
        nil_wires
        |> Enum.map(fn wire ->
          {wire, gates[wire].(wires)}
        end)
        |> Map.new()

      wires =
        Map.merge(wires, new_wire_values)

      remaining_nil_wires =
        new_wire_values
        |> Enum.filter(&is_nil(elem(&1, 1)))
        |> Enum.map(&elem(&1, 0))
        |> MapSet.new()

      if remaining_nil_wires == nil_wires do
        {:error, remaining_nil_wires}
      else
        run(wires, remaining_nil_wires, gates)
      end
    end
  end

  @doc """
  returns:
  wires as map of wire values: true | false | nil
  gates as map of wire => function that uses pattern matching on map of wires to get input values
  """
  def parse_input(input) do
    {wire_lines, gate_lines} =
      input
      |> String.split("\n")
      |> Enum.split_while(fn x -> x != "" end)

    wires =
      wire_lines
      |> Enum.map(fn <<
                       wire::binary-size(3),
                       ": ",
                       value::binary-size(1)
                     >> ->
        value = value == "1"
        {wire, value}
      end)
      |> Map.new()

    {wires, gates} =
      gate_lines
      |> Enum.drop(1)
      |> Enum.reduce({wires, %{}}, fn line, {wires, gates} ->
        {wire1, wire2, wire_out, gate} =
          case line do
            <<
              wire1::binary-size(3),
              " AND ",
              wire2::binary-size(3),
              " -> ",
              wire_out::binary-size(3)
            >> ->
              {wire1, wire2, wire_out, :and}

            <<
              wire1::binary-size(3),
              " XOR ",
              wire2::binary-size(3),
              " -> ",
              wire_out::binary-size(3)
            >> ->
              {wire1, wire2, wire_out, :xor}

            <<
              wire1::binary-size(3),
              " OR ",
              wire2::binary-size(3),
              " -> ",
              wire_out::binary-size(3)
            >> ->
              {wire1, wire2, wire_out, :or}
          end

        wires =
          wires
          |> Map.put_new(wire1, nil)
          |> Map.put_new(wire2, nil)
          |> Map.put_new(wire_out, nil)

        gate_fn =
          case gate do
            :and ->
              fn
                %{^wire1 => x, ^wire2 => y} when is_nil(x) or is_nil(y) -> nil
                %{^wire1 => x, ^wire2 => y} -> x && y
              end

            :or ->
              fn
                %{^wire1 => x, ^wire2 => y} when is_nil(x) or is_nil(y) -> nil
                %{^wire1 => x, ^wire2 => y} -> x || y
              end

            :xor ->
              fn
                %{^wire1 => x, ^wire2 => y} when is_nil(x) or is_nil(y) -> nil
                %{^wire1 => x, ^wire2 => y} -> x != y
              end
          end

        gates =
          gates
          |> Map.put(wire_out, gate_fn)

        {wires, gates}
      end)

    nil_wires =
      wires
      |> Enum.filter(fn {_, val} -> is_nil(val) end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    {wires, nil_wires, gates}
  end
end
