defmodule RowProcessor do
  def process_rows() do
    safe_rows =
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&compare_values_in_row/1)
    |> Enum.reduce(fn acc, safe -> safe + acc end)

    safe_rows
  end

  defp parse_line(line) do
    parsed = line
    |> String.split()
    |> Enum.map(&parse_integer/1)
    parsed
  rescue
    ArgumentError -> {:error, "Incorrect Line format: #{line}"}
  end

  defp parse_integer(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> raise ArgumentError, message: "Invalid input: #{value}"
    end
  end

  defp compare_values_in_row(row) do
    # Increasing by [1,3] always, or Decreasing by [1,3] always
    count = Enum.reduce_while(row, {nil, 0}, fn current, {previous, previous_change} ->
      IO.puts("Previous: #{previous}, current: #{current}")
      cond do
      previous != nil ->
        current_change = (current - previous)

        # If the difference is in the different direction, too big, or too small, halt.
        cond do
          (previous_change > 0) and (current_change <= 0) -> {:halt, {0, 0}}
          (previous_change < 0) and (current_change >= 0) -> {:halt, {0, 0}}
          (current_change > 3) or (current_change < -3) -> {:halt, {0, 0}}
          current_change == 0 -> {:halt, {0, 0}}
          true -> {:cont, {current, current_change}}
        end
      true -> {:cont, {current, 0}}
      end
    end)
    IO.puts("Row: #{inspect(row)}")
    IO.puts("Count: #{inspect(count)}")
    if count != {0, 0} do
      IO.puts("Safe row: #{inspect(row)}")
      1
    else
      0
    end
  end

end

safe_rows = RowProcessor.process_rows()

IO.puts("Safe rows: #{safe_rows}") # 347 is too high!
