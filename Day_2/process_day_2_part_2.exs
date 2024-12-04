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
    #IO.inspect(parsed, label: "Parsed line")
    parsed
  rescue
    ArgumentError -> {:error, "Incorrect Line format: #{line}"}
  end

  defp parse_integer(value) do
    case Integer.parse(value) do
      {int, _} -> int  # Successfully parsed integer
      :error -> raise ArgumentError, message: "Invalid input: #{value}"
    end
  end

  defp validate_sequence(row, max_removable) do
    IO.puts("\nRow: #{inspect(row, charlists: :as_lists)}")
    count = Enum.reduce_while(row, {nil, 0, 0}, fn current, {previous, previous_change, number_removed} ->
      IO.puts("Previous: #{previous}, current: #{current}, number removed: #{number_removed}")
      cond do
      previous != nil ->
        current_change = (current - previous)

        # If the difference is in the different direction, too big, or too small, halt.
        cond do
          ((previous_change > 0) and (current_change <= 0)) or
          ((previous_change < 0) and (current_change >= 0)) or
          (current_change > 3) or (current_change < -3) or current_change == 0 ->
            # If we've reached a halting condition, skip the current number and retry.
            IO.puts("Removing why?: previous change: #{previous_change}, current change: #{current_change}")
            IO.puts("Possibly halting!, already removed: #{number_removed}, removing #{current}")
            cond do
              number_removed < max_removable -> {:cont, {previous, previous_change, 1}}
              true -> {:halt, 0}
            end

          true -> {:cont, {current, current_change, number_removed}}
        end
      true -> {:cont, {current, 0, 0}}
      end
    end)
    IO.puts("Count: #{inspect(count)}")
    if count != 0 do
      IO.puts("Safe row: #{inspect(row, charlists: :as_lists)}")
      1
    else
      IO.puts("Unsafe row: #{inspect(row, charlists: :as_lists)}")
      0
    end
  end

  defp compare_values_in_row(row) do
    first = validate_sequence(row, 1)
    cond do
      first == 1 -> 1
      first == 0 ->
          any_valid_subsequences =
            Enum.any?(0..(length(row) - 1), fn index ->
              subsequence = List.delete_at(row, index)
              result = validate_sequence(subsequence, 0)
              cond do
                result == 1 -> true
                result == 0 -> false
              end
            end)
          cond do
            any_valid_subsequences == true -> 1
            true -> 0
          end
    end
  end

end

safe_rows = RowProcessor.process_rows()

IO.puts("Safe rows: #{safe_rows}") # 346 is too low.
