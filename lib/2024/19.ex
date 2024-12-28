import AOC

aoc 2024, 19 do
  use Memoize

  def p1(input) do
    {towels, patterns} = parse_input(input)

    patterns
    |> Enum.filter(&can_form_pattern?(&1, towels))
    |> Enum.count()
  end

  defmemo can_form_pattern?("", _) do
    true
  end

  defmemo can_form_pattern?(pattern, towels) do
    towels
    |> Enum.map(fn towel ->
      if String.starts_with?(pattern, towel) do
        pattern
        |> String.split_at(String.length(towel))
        |> elem(1)
        |> can_form_pattern?(towels)
      else
        false
      end
    end)
    |> Enum.any?(& &1)
  end

  def parse_input(input) do
    lines =
      input
      |> String.split("\n")

    towels =
      lines
      |> Enum.at(0)
      |> String.split(", ")

    patterns =
      lines
      |> Enum.drop(2)

    {towels, patterns}
  end

  def p2(input) do
    {towels, patterns} = parse_input(input)

    patterns
    |> Enum.map(&ways_to_make_pattern(&1, towels))
    |> Enum.sum()
  end

  defmemo ways_to_make_pattern("", _) do
    1
  end

  defmemo ways_to_make_pattern(pattern, towels) do
    # IO.inspect(pattern)

    towels
    |> Enum.map(fn towel ->
      if String.starts_with?(pattern, towel) do
        pattern
        |> String.split_at(String.length(towel))
        |> elem(1)
        |> ways_to_make_pattern(towels)
      else
        0
      end
    end)
    # |> IO.inspect()
    |> Enum.sum()
  end
end
