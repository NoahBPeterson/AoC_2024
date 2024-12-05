defmodule SequenceParser do
  def parse_sequence(input) do
    regex = ~r/mul\((\d+),(\d+)\)/

    input
    # Find all matches
    |> Enum.flat_map(fn line ->
        Regex.scan(regex, line)
        |> Enum.map(fn [throwaway, first, second] ->
          IO.puts("#{throwaway} #{first} #{second}")
          {String.to_integer(first), String.to_integer(second)}
        end)
      end)
      # Multiply the two integers in each `mul(x,y)` pair, sum them all
      |> Enum.reduce(0, fn {x, y}, acc -> acc + (x * y) end)
  end


  def parse_sequence_do_dont(input) do
    regex = ~r/mul\((\d+),(\d+)\)/

    final = input
    # Find all matches
    |> Enum.map(fn line ->
        line
        |> String.split("don't()")
        |> Enum.with_index()
        |> Enum.flat_map(fn {segment, index} ->
            cond do
              index == 0 ->
                Regex.scan(regex, segment)
                |> Enum.map(fn [throwaway, first, second] ->
                  IO.puts("First index: #{throwaway} #{first} #{second}")
                  {String.to_integer(first), String.to_integer(second)}
                end)
              String.contains?(segment, "do()") ->
                [_, after_do] = String.split(segment, "do()", parts: 2, trim: true)
                Regex.scan(regex, after_do)
                |> Enum.map(fn [throwaway, first, second] ->
                  IO.puts("Not first index: #{throwaway} #{first} #{second}")
                  {String.to_integer(first), String.to_integer(second)}
                end)
              true -> []
            end
        end)
        |> Enum.reduce(0, fn {x, y}, acc -> acc + (x * y) end)
      end)
      |> Enum.reduce(0, fn x, acc -> acc + x end)
      # Multiply the two integers in each `mul(x,y)` pair, sum them all
      final
  end
end

input = IO.stream(:stdio, :line) |> Enum.map(&String.trim/1)

result = SequenceParser.parse_sequence(input)
IO.inspect(result, label: "Matched sequences")

result_part_2 = SequenceParser.parse_sequence_do_dont(input)
IO.inspect(result_part_2, label: "Matched sequences, part 2", charlists: :as_lists) # 107,307,267 is too high (fixed by removing newlines)
