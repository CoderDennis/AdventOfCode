import AOC

aoc 2024, 24 do
  def p1(input) do
    {wires, gates} = parse_input(input)

    run(wires, gates)
  end

  def p2(input) do
    {wires, gates} =
      parse_input(input)

    # borrows implementation from https://github.com/eagely/adventofcode/blob/main/src/main/kotlin/solutions/y2024/Day24.kt shared via reddit
    # I worked on my approach for 3 days before reading reddit and trying to adopt this approach.

    nxz =
      gates
      |> Enum.filter(fn
        {"z45", _} -> false
        {_z, {_a, _b, :xor}} -> false
        {<<"z", _wire_number::binary-size(2)>>, _} -> true
        _ -> false
      end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()
      |> IO.inspect()

    xnz =
      gates
      |> Enum.filter(fn
        {<<"z", _::binary-size(2)>>, _} -> false
        {_, {<<"x", _::binary-size(2)>>, <<"y", _::binary-size(2)>>, _}} -> false
        {_, {<<"y", _::binary-size(2)>>, <<"x", _::binary-size(2)>>, _}} -> false
        {_, {_, _, :xor}} -> true
        _ -> false
      end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()
      |> IO.inspect()

    gates =
      xnz
      |> Enum.reduce(gates, fn i, gates ->
        b = first_z_that_uses_out(gates, i)
        swap_gates(gates, i, b)
      end)

    falseCarry =
      (get_number(wires, "x") + get_number(wires, "y"))
      |> Bitwise.bxor(run(wires, gates))
      |> count_trailing_zeros()
      |> Integer.to_string()

    [
      gates
      |> Enum.filter(fn {_, {a, b, _}} ->
        String.ends_with?(a, falseCarry) and String.ends_with?(b, falseCarry)
      end)
      |> Enum.map(&elem(&1, 0)),
      nxz,
      xnz
    ]
    |> Enum.concat()
    |> Enum.sort()
    |> Enum.join(",")
  end

  def first_z_that_uses_out(gates, gate_out) do
    # IO.inspect(gate_out)

    {out, _} =
      gates
      |> Enum.find({"abc", nil}, fn {_, {a, b, _}} -> a == gate_out or b == gate_out end)

    if String.starts_with?(out, "z") do
      out
      |> String.slice(1, 2)
      |> String.to_integer()
      |> then(&(&1 - 1))
      |> Integer.to_string()
      |> String.pad_leading(2, "0")
      |> then(&"z#{&1}")
    else
      first_z_that_uses_out(gates, out)
    end
  end

  def count_trailing_zeros(number) do
    number
    |> Integer.digits(2)
    |> Enum.reverse()
    |> Enum.take_while(&(&1 == 0))
    |> Enum.count()
  end

  def swap_gates(gates, x, y) do
    IO.inspect({x, y}, label: "swap_gates")

    x_val = Map.get(gates, x)
    y_val = Map.get(gates, y)

    gates
    |> Map.put(x, y_val)
    |> Map.put(y, x_val)
  end

  def get_number(wires, starts_with) do
    get_binary_digits(wires, starts_with)
    |> Integer.undigits(2)
  end

  def get_binary_digits(wires, starts_with) do
    wires
    |> Enum.filter(fn {wire, _value} -> String.starts_with?(wire, starts_with) end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    # |> IO.inspect()
    |> Enum.map(fn
      {_, true} -> 1
      _ -> 0
    end)
  end

  @doc """
  returns dictionary of wire_name => true/false values for the given number
  """
  def number_to_wires(number, starts_with) do
    number
    |> Integer.digits(2)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {digit, index} ->
      wire =
        index
        |> Integer.to_string()
        |> String.pad_leading(2, "0")
        |> then(&"#{starts_with}#{&1}")

      {wire, digit == 1}
    end)
    |> Map.new()
  end

  def wires_for_number(wires, starts_with) do
    wires
    |> Enum.filter(fn {wire, _value} -> String.starts_with?(wire, starts_with) end)
  end

  def set_number(wires, number, starts_with) do
    number_wires = number_to_wires(number, starts_with)
    # Map.merge(wires, number_wires)

    wires
    |> wires_for_number(starts_with)
    |> Enum.reduce(wires, fn {k, _v}, wires ->
      Map.put(wires, k, Map.get(number_wires, k, false))
    end)
  end

  def run(wires, gates) do
    nil_wires =
      wires
      |> Enum.filter(&is_nil(elem(&1, 1)))
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    if MapSet.size(nil_wires) == 0 do
      get_number(wires, "z")
    else
      new_wire_values =
        nil_wires
        |> Enum.map(fn wire ->
          {wire, gate_fn(wires, gates[wire])}
        end)
        |> Map.new()

      wires =
        Map.merge(wires, new_wire_values)

      run(wires, gates)
    end
  end

  def gate_fn(wires, {wire1, wire2, gate}) do
    x = Map.get(wires, wire1)
    y = Map.get(wires, wire2)

    do_gate(x, y, gate)
  end

  def do_gate(nil, _, _), do: nil
  def do_gate(_, nil, _), do: nil

  def do_gate(x, y, :and), do: x && y
  def do_gate(x, y, :or), do: x || y
  def do_gate(x, y, :xor), do: x != y

  @doc """
  returns:
  wires as map of wire values: true | false | nil
  gates as map of wire => tuple of {wire1, wire2, op}
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

        gates =
          gates
          |> Map.put(wire_out, {wire1, wire2, gate})

        {wires, gates}
      end)

    {wires, gates}
  end
end
