import AOC

aoc 2022, 16 do
  use Memoize

  def p1(input) do
    parse_input(input)
    |> explore("AA", 30, 0)
  end

  def p2 do
  end

  defmemo(explore(_valves, _current, 1, pressure), do: pressure)

  defmemo explore(valves, current, time, pressure) do
    if Enum.all?(valves, fn
         {_, :open, _} -> true
         {0, _, _} -> true
         _ -> false
       end) do
      pressure
    else
      {flow_rate, is_open, tunnels} = valves[current]

      open_this_valve =
        if is_open == :closed and flow_rate > 0,
          do:
            explore(
              Map.put(valves, current, {flow_rate, :open, tunnels}),
              current,
              time - 1,
              pressure + flow_rate * (time - 1)
            ),
          else: 0

      [
        open_this_valve
        | tunnels |> Enum.map(fn valve -> explore(valves, valve, time - 1, pressure) end)
      ]
      |> Enum.max()
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.reduce(%{}, fn [
                             _valve,
                             valve,
                             _has,
                             _flow,
                             "rate=" <> rate,
                             _tunnels,
                             _lead,
                             _to,
                             _valves | tunnels
                           ],
                           map ->
      Map.put(
        map,
        valve,
        {rate |> String.trim_trailing(";") |> String.to_integer(), :closed,
         tunnels |> Enum.map(&String.trim_trailing(&1, ","))}
      )
    end)
  end
end
