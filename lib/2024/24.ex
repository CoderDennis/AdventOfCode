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
    # expect each correct pair swap to affect 12 bits, with the last one affecting the most significant 10 bits

    # {get_binary_digits(wires, "x"), get_binary_digits(wires, "y")}

    ones = Stream.repeatedly(fn -> 1 end) |> Enum.take(12)
    zeros = Stream.repeatedly(fn -> 0 end) |> Enum.take(12)

    all_ones_value =
      Stream.repeatedly(fn -> 1 end)
      |> Enum.take(46)
      |> Integer.undigits(2)

    y1 =
      ones
      |> Integer.undigits(2)

    x1 = all_ones_value - y1

    IO.inspect({x1, y1})

    {swap1, swap2} =
      wires
      |> set_number(x1, "x")
      |> set_number(y1, "y")
      |> swap_so_addition_works(nil_wires, gates, 12)
      |> IO.inspect()

    y2 = Enum.concat(ones, zeros) |> Integer.undigits(2)
    x2 = all_ones_value - y2

    gates = swap_gates(gates, swap1, swap2)

    {swap3, swap4} =
      wires
      |> set_number(x2, "x")
      |> set_number(y2, "y")
      |> swap_so_addition_works(nil_wires, gates, 24)
      |> IO.inspect()

    gates = swap_gates(gates, swap3, swap4)

    y3 = Enum.concat([ones, zeros, zeros]) |> Integer.undigits(2)
    x3 = all_ones_value - y3

    {swap5, swap6} =
      wires
      |> set_number(x3, "x")
      |> set_number(y3, "y")
      |> swap_so_addition_works(nil_wires, gates, 36)
      |> IO.inspect()

    gates = swap_gates(gates, swap5, swap6)

    y4 = Enum.concat([ones |> Enum.take(10), zeros, zeros, zeros]) |> Integer.undigits(2)
    x4 = all_ones_value - y4

    {swap7, swap8} =
      wires
      |> set_number(x4, "x")
      |> set_number(y4, "y")
      |> swap_so_addition_works(nil_wires, gates, 56)
      |> IO.inspect()

    [swap1, swap2, swap3, swap4, swap5, swap6, swap7, swap8]
    |> Enum.sort()
    |> Enum.join(",")
  end

  def swap_so_addition_works(wires, nil_wires, gates, digit_count) do
    x =
      get_number(wires, "x")
      |> IO.inspect(label: "x")

    y =
      get_number(wires, "y")
      |> IO.inspect(label: "y")

    expected_z = x + y

    IO.inspect(expected_z, label: "expected_z")

    expected_z |> Integer.digits(2) |> IO.inspect()

    # when swapping gate output wires, we could create loops or configurations that don't terminate
    gate_keys = Map.keys(gates)

    pairs =
      for(x <- gate_keys, y <- gate_keys, x != y, do: [x, y] |> Enum.sort() |> List.to_tuple())
      |> Enum.uniq()

    pairs
    |> Enum.drop_while(fn {x, y} ->
      # IO.inspect({x, y})
      swapped_gates = swap_gates(gates, x, y)

      case run(wires, nil_wires, swapped_gates) do
        {:ok, wire_values} ->
          if digit_count > 36 do
            wire_values |> get_number("z") != expected_z
          else
            count_z_digits(wire_values) < digit_count
          end

        {:error, _} ->
          true
      end
    end)
    |> Enum.at(0)
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

  def count_z_digits(wires) do
    wires
    |> Enum.filter(fn {wire, _value} -> String.starts_with?(wire, "z") end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.take_while(& &1)
    # |> IO.inspect()
    |> Enum.count()
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
