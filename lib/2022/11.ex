import AOC

aoc 2022, 11 do
  def p1 do
    solve(20)
  end

  # 17457804000 was too high

  def p2 do
    solve(10000)
  end

  def solve(rounds) do
    monkeys = input_monkeys()

    1..rounds
    |> Enum.reduce(monkeys, fn _, monkeys ->
      do_round(monkeys)
    end)
    |> Enum.map(fn {_, %{count: count}} -> count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def do_round(monkeys) do
    0..(Enum.count(Map.keys(monkeys)) - 1)
    |> Enum.reduce(monkeys, &turn/2)
  end

  @example_mod 23 * 19 * 13 * 17
  @mod 13 * 2 * 7 * 17 * 5 * 11 * 3 * 19

  def turn(monkey_index, monkeys) do
    monkey = monkeys[monkey_index]
    new_count = Enum.count(monkey.items) + monkey.count

    monkeys =
      monkey.items
      |> Enum.reduce(monkeys, fn item, monkeys ->
        new =
          item
          |> monkey.op.()
          |> rem(@mod)

        # |> div(3)

        send_to = monkey.test.(new)

        Map.replace!(
          monkeys,
          send_to,
          Map.replace!(monkeys[send_to], :items, [new | monkeys[send_to].items])
        )
      end)

    Map.replace!(monkeys, monkey_index, Map.merge(monkey, %{items: [], count: new_count}))
  end

  def example_monkeys() do
    %{
      0 => %{
        items: [79, 98],
        op: fn old -> old * 19 end,
        test: fn x -> if rem(x, 23) == 0, do: 2, else: 3 end,
        count: 0
      },
      1 => %{
        items: [54, 65, 75, 74],
        op: fn old -> old + 6 end,
        test: fn x -> if rem(x, 19) == 0, do: 2, else: 0 end,
        count: 0
      },
      2 => %{
        items: [79, 60, 97],
        op: fn old -> old * old end,
        test: fn x -> if rem(x, 13) == 0, do: 1, else: 3 end,
        count: 0
      },
      3 => %{
        items: [74],
        op: fn old -> old + 3 end,
        test: fn x -> if rem(x, 17) == 0, do: 0, else: 1 end,
        count: 0
      }
    }
  end

  def input_monkeys() do
    %{
      0 => %{
        items: [84, 72, 58, 51],
        op: fn old -> old * 3 end,
        test: fn x -> if rem(x, 13) == 0, do: 1, else: 7 end,
        count: 0
      },
      1 => %{
        items: [88, 58, 58],
        op: fn old -> old + 8 end,
        test: fn x -> if rem(x, 2) == 0, do: 7, else: 5 end,
        count: 0
      },
      2 => %{
        items: [93, 82, 71, 77, 83, 53, 71, 89],
        op: fn old -> old * old end,
        test: fn x -> if rem(x, 7) == 0, do: 3, else: 4 end,
        count: 0
      },
      3 => %{
        items: [81, 68, 65, 81, 73, 77, 96],
        op: fn old -> old + 2 end,
        test: fn x -> if rem(x, 17) == 0, do: 4, else: 6 end,
        count: 0
      },
      4 => %{
        items: [75, 80, 50, 73, 88],
        op: fn old -> old + 3 end,
        test: fn x -> if rem(x, 5) == 0, do: 6, else: 0 end,
        count: 0
      },
      5 => %{
        items: [59, 72, 99, 87, 91, 81],
        op: fn old -> old * 17 end,
        test: fn x -> if rem(x, 11) == 0, do: 2, else: 3 end,
        count: 0
      },
      6 => %{
        items: [86, 69],
        op: fn old -> old + 6 end,
        test: fn x -> if rem(x, 3) == 0, do: 1, else: 0 end,
        count: 0
      },
      7 => %{
        items: [91],
        op: fn old -> old + 1 end,
        test: fn x -> if rem(x, 19) == 0, do: 2, else: 5 end,
        count: 0
      }
    }
  end
end
