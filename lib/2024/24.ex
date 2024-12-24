import AOC

aoc 2024, 24 do
  def p1(input) do
    {wires, gates} = parse_input(input)

    nil_wires =
      wires
      |> Enum.filter(fn {_, val} -> is_nil(val) end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    run(wires, nil_wires, gates)
    |> Enum.filter(fn {wire, _value} -> String.starts_with?(wire, "z") end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(fn
      {_, true} -> 1
      {_, false} -> 0
    end)
    |> Integer.undigits(2)
  end

  def run(wires, nil_wires, gates) do
    if MapSet.size(nil_wires) == 0 do
      wires
    else
      new_wire_values =
        nil_wires
        |> Enum.map(fn wire ->
          {wire, gates[wire].(wires)}
        end)
        |> Map.new()

      wires =
        Map.merge(wires, new_wire_values)

      nil_wires =
        new_wire_values
        |> Enum.filter(&is_nil(elem(&1, 1)))
        |> Enum.map(&elem(&1, 0))
        |> MapSet.new()

      run(wires, nil_wires, gates)
    end
  end

  def p2(input) do
    parse_input(input)
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
  end
end
