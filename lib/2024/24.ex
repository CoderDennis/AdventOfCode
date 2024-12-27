import AOC

aoc 2024, 24 do
  def p1(input) do
    {wires, gates} = parse_input(input)

    {:ok, wire_values} = run(wires, gates)

    wire_values
    |> get_number("z")
  end

  def p2(input) do
    {wires, gates} = parse_input(input)

    {wires, gates}
    # dhm,gsv,kcv,mrb,pnr,z00,z08,z16 was the wrong answer
    # btj,crw,fpk,kcv,kvn,qjd,rkm,tkv also wrong
    # jbc,kcv,mrb,rkm,swk,tnr,z08,z16 also wrong
  end

  def swap_gates(gates, x, y) do
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
      {:ok, wires}
    else
      new_wire_values =
        nil_wires
        |> Enum.map(fn wire ->
          {wire, gate_fn(wires, gates[wire])}
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
        run(wires, gates)
      end
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

        gates =
          gates
          |> Map.put(wire_out, {wire1, wire2, gate})

        {wires, gates}
      end)

    {wires, gates}
  end
end
