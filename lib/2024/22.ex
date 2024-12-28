import AOC

aoc 2024, 22 do
  def p1(input) do
    # 123
    # |> secret_number_stream()
    # |> Enum.take(10)

    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn n ->
      n
      |> secret_number_stream()
      |> Enum.at(2000)
    end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def p2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&get_prices/1)
    |> Enum.map(fn price_list ->
      price_list
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] ->
        {b, b - a}
      end)
    end)
    |> Enum.map(fn changing_price_list ->
      changing_price_list
      |> Enum.chunk_every(4, 1, :discard)
      |> Enum.reduce(%{}, fn [{_, a}, {_, b}, {_, c}, {v, d}], map ->
        key = {a, b, c, d}
        Map.put_new(map, key, v)
      end)
    end)
    |> Enum.reduce(%{}, fn sequence_map, total_map ->
      Map.merge(total_map, sequence_map, fn _k, v1, v2 ->
        v1 + v2
      end)
    end)
    |> Map.values()
    |> Enum.max()
  end

  def get_prices(n) do
    n
    |> secret_number_stream()
    |> Stream.map(fn x ->
      x
      |> Integer.digits()
      |> Enum.at(-1)
    end)
    |> Enum.take(2000)
  end

  def secret_number_stream(number) do
    Stream.unfold(number, fn n ->
      next =
        n
        |> mix(n * 64)
        |> prune()
        |> then(fn x -> mix(x, div(x, 32)) end)
        |> prune()
        |> then(fn x -> mix(x, x * 2048) end)
        |> prune

      {n, next}
    end)
  end

  def mix(n, m) do
    Bitwise.bxor(n, m)
  end

  def prune(number) do
    Integer.mod(number, 16_777_216)
  end
end
