import AOC

aoc 2024, 17 do
  def p1(input) do
    [line_A, line_B, line_C, _, program_line] =
      input
      |> String.split("\n")

    a = parse_register_value(line_A)
    b = parse_register_value(line_B)
    c = parse_register_value(line_C)

    %{a: a, b: b, c: c}

    program = parse_program(program_line)

    run(program, 0, %{a: a, b: b, c: c}, [])
  end

  def run(program, instruction_pointer, _, output)
      when not is_map_key(program, instruction_pointer) do
    output
    |> Enum.reverse()
    |> Enum.join(",")
  end

  def run(program, instruction_pointer, %{a: a, b: b, c: c} = registers, output) do
    [new_instruction_pointer, updated_registers, updated_output] =
      case {Map.get(program, instruction_pointer), Map.get(program, instruction_pointer + 1)} do
        {0, operand} ->
          val = div(a, Integer.pow(2, combo_operand(operand, registers)))
          [instruction_pointer + 2, %{registers | a: val}, output]

        {1, operand} ->
          val = Bitwise.bxor(b, operand)
          [instruction_pointer + 2, %{registers | b: val}, output]

        {2, operand} ->
          val = Integer.mod(combo_operand(operand, registers), 8)
          [instruction_pointer + 2, %{registers | b: val}, output]

        {3, _} when a == 0 ->
          [instruction_pointer + 2, registers, output]

        {3, operand} ->
          [operand, registers, output]

        {4, _} ->
          val = Bitwise.bxor(b, c)
          [instruction_pointer + 2, %{registers | b: val}, output]

        {5, operand} ->
          val = Integer.mod(combo_operand(operand, registers), 8)
          [instruction_pointer + 2, registers, [val | output]]

        {6, operand} ->
          val = div(a, Integer.pow(2, combo_operand(operand, registers)))
          [instruction_pointer + 2, %{registers | b: val}, output]

        {7, operand} ->
          val = div(a, Integer.pow(2, combo_operand(operand, registers)))
          [instruction_pointer + 2, %{registers | c: val}, output]
      end

    run(program, new_instruction_pointer, updated_registers, updated_output)
  end

  def combo_operand(operand, _registers) when operand < 4, do: operand
  def combo_operand(4, %{a: a}), do: a
  def combo_operand(5, %{b: b}), do: b
  def combo_operand(6, %{c: c}), do: c

  def parse_register_value(line) do
    {_, val} =
      line
      |> String.split_at(12)

    String.to_integer(val)
  end

  def parse_program(line) do
    [_, val] = String.split(line, " ")

    val
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {c, i} -> {i, c} end)
    |> Map.new()
  end

  def p2(input) do
    [_line_A, line_B, line_C, _, program_line] =
      input
      |> String.split("\n")

    # a = parse_register_value(line_A)
    b = parse_register_value(line_B)
    c = parse_register_value(line_C)

    program = parse_program(program_line)

    program_text =
      program
      |> Map.values()
      |> Enum.join(",")

    # Stream.iterate(1, &(&1 * 10))
    # |> Stream.drop_while(fn a ->
    #   output = run(program, 0, %{a: a, b: b, c: c}, [])
    #   IO.inspect({String.length(output), a, output})
    #   # find order of magnitude of output with correct length
    #   String.length(output) <= String.length(program_text)
    # end)
    # |> Enum.at(0)

    # recompile the following bounds checks with exponentially smaller steps

    # Stream.iterate(35_184_372_100_000, &(&1 - 1))
    # |> Stream.drop_while(fn a ->
    #   output = run(program, 0, %{a: a, b: b, c: c}, [])
    #   IO.inspect({String.length(output), a, output})
    #   # find lower bound of correct length
    #   String.length(output) == String.length(program_text)
    # end)
    # |> Enum.at(0)

    # Stream.iterate(281_474_976_711_000, &(&1 - 1))
    # |> Stream.drop_while(fn a ->
    #   output = run(program, 0, %{a: a, b: b, c: c}, [])
    #   IO.inspect({String.length(output), a, output})
    #   # find upper bound of correct length
    #   String.length(output) > String.length(program_text)
    # end)
    # |> Enum.at(0)

    # Stream.iterate(35_184_372_100_000, &(&1 + 1))
    # |> Stream.drop_while(fn a ->
    #   output = run(program, 0, %{a: a, b: b, c: c}, [])
    #   IO.inspect({String.length(output), a, output})
    #   output != program_text
    # end)
    # |> Enum.at(0)

    Stream.unfold(35_184_372_100_000, fn a ->
      output = run(program, 0, %{a: a, b: b, c: c}, [])
      match_score = match_score(output, program_text)
      IO.inspect({String.length(output), a, output, match_score})

      case match_score do
        31 ->
          nil

        score when score > 18 ->
          {a, a + 1}

        score when score > 16 ->
          {a, a + 1000}

        score when score > 8 ->
          {a, a + 1_000_000}

        _ ->
          {a, a + 1_000_000_000}
      end
    end)
    |> Stream.run()

    #
  end

  for char_len <- 31..1//-1 do
    def match_score(
          <<
            _::binary-size(unquote(31 - char_len)),
            match::binary-size(unquote(char_len))
          >>,
          <<
            _::binary-size(unquote(31 - char_len)),
            match::binary-size(unquote(char_len))
          >>
        ),
        do: unquote(char_len)
  end

  def match_score(_, _), do: 0
end
