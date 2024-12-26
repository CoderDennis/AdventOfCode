import AOC

aoc 2024, 24 do
  def p1(input) do
    {wires, nil_wires, gates} = parse_input(input)

    {:ok, wire_values} = run(wires, nil_wires, gates)

    {wires, nil_wires, gates,
     wire_values
     |> get_number("z")}
  end

  def p2(input) do
    {wires, nil_wires, gates} = parse_input(input)

    # optimizaion strategy: look for matching bits with a given swap,
    # then look for another swap that matches more bits
    # expect each correct pair swap to affect 12 bits, with the last one affecting the most significant 10 bits

    # {get_binary_digits(wires, "x"), get_binary_digits(wires, "y")}

    # I want Integer.pow(2, 56) - 1 to be the expected z answer.

    x = Integer.pow(2, 45) - 1
    y = 1

    wires =
      wires
      |> set_number(x, "x")
      |> set_number(y, "y")

    {swap1, swap2} =
      swap_for_most_bits(wires, nil_wires, gates, MapSet.new())
      |> IO.inspect()

    gates = swap_gates(gates, swap1, swap2)

    swapped = MapSet.new([swap1, swap2])

    {swap3, swap4} =
      swap_for_most_bits(wires, nil_wires, gates, swapped)
      |> IO.inspect()

    gates = swap_gates(gates, swap3, swap4)

    swapped =
      swapped
      |> MapSet.put(swap3)
      |> MapSet.put(swap4)

    wires =
      wires
      |> set_number(y, "x")
      |> set_number(x, "y")

    {swap5, swap6} =
      swap_for_most_bits(wires, nil_wires, gates, swapped)
      |> IO.inspect()

    gates = swap_gates(gates, swap5, swap6)

    swapped =
      swapped
      |> MapSet.put(swap5)
      |> MapSet.put(swap6)

    {swap7, swap8} =
      swap_for_most_bits(wires, nil_wires, gates, swapped)

    [swap1, swap2, swap3, swap4, swap5, swap6, swap7, swap8]
    |> Enum.sort()
    |> Enum.join(",")

    # dhm,gsv,kcv,mrb,pnr,z00,z08,z16 was the wrong answer
    # btj,crw,fpk,kcv,kvn,qjd,rkm,tkv also wrong
    # jbc,kcv,mrb,rkm,swk,tnr,z08,z16 also wrong

    # {{"tnr", "z08"}, 16}
    # {"tnr", "z08"}
    # {{"mrb", "z16"}, 32}
    # {"mrb", "z16"}
    # {{"jbc", "kcv"}, 46}
    # {"jbc", "kcv"}
    # {{"rkm", "swk"}, 46}
  end

  def swap_for_most_bits(wires, nil_wires, gates, already_swapped) do
    # x =
    #   get_number(wires, "x")
    #   |> IO.inspect(label: "x")

    # y =
    #   get_number(wires, "y")
    #   |> IO.inspect(label: "y")

    # expected_z = x + y

    # IO.inspect(expected_z, label: "expected_z")

    # expected_z |> Integer.digits(2) |> IO.inspect()

    # when swapping gate output wires, we could create loops or configurations that don't terminate
    gate_keys =
      Map.keys(gates)
      |> MapSet.new()
      |> MapSet.difference(already_swapped)

    pairs =
      for(x <- gate_keys, y <- gate_keys, x != y, do: [x, y] |> Enum.sort() |> List.to_tuple())
      |> Enum.uniq()

    pairs
    |> Enum.map(fn {x, y} ->
      # IO.inspect({x, y})

      {{x, y}, score_system(wires, nil_wires, swap_gates(gates, x, y))}
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> IO.inspect()
    |> then(&elem(&1, 0))
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

  def score_system(wires, nil_wires, gates) do
    case run(wires, nil_wires, gates) do
      {:error, _} ->
        0

      {:ok, _} ->
        0..45
        |> Enum.take_while(fn digit ->
          check = Integer.pow(2, digit)

          {:ok, digit_wires} =
            wires
            |> set_number(check - 1, "x")
            |> set_number(1, "y")
            |> run(nil_wires, gates)

          digit_wires
          |> get_number("z")
          |> then(&(Bitwise.band(&1, check) == check))
        end)
        |> Enum.count()
    end
  end

  @doc """
  returns dictionary of wire_name => true/false values for the given number
  """
  def number_wires(number, starts_with) do
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
    number_wires = number_wires(number, starts_with)
    # Map.merge(wires, number_wires)

    wires
    |> wires_for_number(starts_with)
    |> Enum.reduce(wires, fn {k, _v}, wires ->
      Map.put(wires, k, Map.get(number_wires, k, false))
    end)
  end

  def run(wires, nil_wires, gates, x \\ nil, y \\ nil) do
    wires =
      if is_nil(x) do
        wires
      else
        wires |> set_number(x, "x")
      end

    wires =
      if is_nil(y) do
        wires
      else
        wires |> set_number(y, "y")
      end

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
