import AOC

aoc 2024, 11 do
  use Memoize

  def p1(input) do
    do_blinks(input, 25)
  end

  def do_blinks(input, blink_count) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Stream.unfold(&blink/1)
    |> Stream.drop(blink_count - 1)
    |> Enum.take(1)
    |> Enum.map(&Enum.count/1)
  end

  def blink(stones) do
    new_stones =
      stones
      |> Stream.flat_map(fn
        0 ->
          [1]

        num ->
          digit_count =
            num
            |> :math.log10()
            |> floor()
            |> then(fn x -> x + 1 end)

          case rem(digit_count, 2) do
            0 ->
              num
              |> Integer.digits()
              |> Enum.split(div(digit_count, 2))
              |> Tuple.to_list()
              |> Enum.map(&Integer.undigits/1)

            _ ->
              [num * 2024]
          end
      end)

    {new_stones, new_stones}
  end

  defmemo count_stones_for_blinks(_stone, 0) do
    1
  end

  defmemo count_stones_for_blinks(0, blinks) do
    count_stones_for_blinks(1, blinks - 1)
  end

  defmemo count_stones_for_blinks(stone, blinks) do
    digit_count =
      stone
      |> :math.log10()
      |> floor()
      |> then(fn x -> x + 1 end)

    case rem(digit_count, 2) do
      0 ->
        stone
        |> Integer.digits()
        |> Enum.split(div(digit_count, 2))
        |> Tuple.to_list()
        |> Enum.map(&Integer.undigits/1)

      _ ->
        [stone * 2024]
    end
    |> Enum.map(fn stone -> count_stones_for_blinks(stone, blinks - 1) end)
    |> Enum.sum()
  end

  def p2(input) do
    # do_blinks(input, 75)

    input
    |> String.split(" ")
    |> Enum.map(fn stone ->
      stone
      |> String.to_integer()
      |> count_stones_for_blinks(75)
    end)
    |> Enum.sum()
  end
end
