import AOC

aoc 2024, 13 do
  use Memoize

  def p1(input) do
    # is the cheapest also the shortest?
    # it doesn't seem like it because button A is more expensive

    input
    |> String.split("\n")
    |> Enum.chunk_every(3, 4)
    |> Enum.map(&play/1)
    |> Enum.reject(&(&1 == :infinity))
    |> Enum.sum()
  end

  def play([a, b, prize]) do
    button_a = button(a)
    button_b = button(b)
    prize = prize(prize)

    play(button_a, button_b, prize, 0, 0)
  end

  defmemo play(
            {ax, ay} = button_a,
            {bx, by} = button_b,
            {prize_x, prize_y} = prize,
            button_a_count,
            button_b_count
          ) do
    case {ax * button_a_count + bx * button_b_count, ay * button_a_count + by * button_b_count} do
      {^prize_x, ^prize_y} ->
        button_a_count * 3 + button_b_count

      {x, y} when x > prize_x or y > prize_y ->
        :infinity

      _ ->
        [
          play(button_a, button_b, prize, button_a_count + 1, button_b_count),
          play(button_a, button_b, prize, button_a_count, button_b_count + 1)
        ]
        |> Enum.min()
    end
  end

  def button(line) do
    ~r/Button .: X\+(\d+), Y\+(\d+)/
    |> get_x_y(line)
  end

  def prize(line) do
    ~r/Prize: X=(\d+), Y=(\d+)/
    |> get_x_y(line)
  end

  defp get_x_y(rx, line) do
    rx
    |> Regex.run(line)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.chunk_every(3, 4)
    |> Enum.map(&play_2/1)
    |> Enum.reject(&(&1 == :infinity))
    |> Enum.sum()
  end

  def play_2([a, b, prize]) do
    button_a = button(a)
    button_b = button(b)
    {x, y} = prize(prize)

    play(button_a, button_b, {x + 10_000_000_000_000, y + 10_000_000_000_000}, 0, 0)
  end
end
