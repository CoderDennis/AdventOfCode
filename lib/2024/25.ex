import AOC

alias Helpers.CoordinateMap

aoc 2024, 25 do
  def p1(input) do
    {locks, keys} = parse_input(input)

    locks =
      locks
      |> Enum.map(&lock_pin_heights/1)

    keys =
      keys
      |> Enum.map(&key_heights/1)

    # {locks, keys}
    combinations = for l <- locks, k <- keys, do: {l, k}

    combinations
    |> Enum.filter(fn {lock, key} ->
      Enum.zip(lock, key)
      |> Enum.all?(fn {l, k} -> l + k <= 5 end)
    end)
    |> Enum.count()
  end

  def p2(input) do
    parse_input(input)
  end

  def lock_pin_heights(lock) do
    0..4
    |> Enum.map(fn col ->
      0..6
      |> Enum.find(fn row ->
        Map.get(lock, {row, col}) == "."
      end)
      |> then(&(&1 - 1))
    end)
  end

  def key_heights(key) do
    0..4
    |> Enum.map(fn col ->
      6..0//-1
      |> Enum.find(fn row ->
        Map.get(key, {row, col}) == "."
      end)
      |> then(&(5 - &1))
    end)
  end

  def parse_input(input) do
    {locks, keys} =
      input
      |> String.split("\n\n")
      |> Enum.map(&CoordinateMap.create/1)
      |> Enum.split_with(&(Map.get(&1, {0, 0}) == "#"))

    {locks, keys}
  end
end
