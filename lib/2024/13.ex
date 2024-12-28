import AOC

aoc 2024, 13 do
  def p1(input) do
    input
    |> String.split("\n")
    |> Enum.chunk_every(3, 4)
    |> Enum.map(&play/1)
    |> Enum.sum()
  end

  def play([a, b, prize], add_to_prize \\ 0) do
    {ax, ay} = button_a = button(a)
    {bx, by} = button_b = button(b)
    {x, y} = prize(prize)

    x = x + add_to_prize
    y = y + add_to_prize

    if Integer.mod(x, Integer.gcd(ax, bx)) == 0 and
         Integer.mod(y, Integer.gcd(ay, by)) == 0 do
      solve(button_a, button_b, {x, y})
    else
      0
    end
  end

  def solve(
        {ax, ay} = _button_a,
        {bx, by} = _button_b,
        {prize_x, prize_y} = _prize
      ) do
    # IO.inspect({button_a, button_b, prize})

    # https://www.google.com/search?q=94x%2B22y%3D8400%3B34x%2B67y%3D5400 -> select "solve using the elimination method"
    a_presses = div(prize_x * by - prize_y * bx, ax * by - bx * ay)
    b_presses = div(prize_y - ay * a_presses, by)

    # IO.inspect({a_presses, b_presses})
    if ax * a_presses + bx * b_presses == prize_x and
         ay * a_presses + by * b_presses == prize_y do
      a_presses * 3 + b_presses
    else
      0
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
    |> Enum.map(&play(&1, 10_000_000_000_000))
    |> Enum.sum()
  end
end
