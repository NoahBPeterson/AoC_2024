defmodule FileProcessor do
  def process_input_stream() do
    {col1, col2} =
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce({[], []}, fn
      {:error, msg}, acc ->
          IO.puts("Error: #{msg}")
          acc

        {a, b}, {list1, list2} ->
          {[a | list1], [b | list2]}
      end)
    # Sort the columns
    sorted_col1 = Enum.sort(col1)
    sorted_col2 = Enum.sort(col2)

    # Compare the sorted columns
    compare_columns(sorted_col1, sorted_col2)

    # Count frequencies in each column
    # col1_frequencies = Enum.frequencies(col1)
    col2_frequencies = Enum.frequencies(col2)

    multiply_by_frequency(col1, col2_frequencies)
  end

  defp parse_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> to_tuple()
  rescue
    ArgumentError -> {:error, "Incorrect Line format: #{line}"}
  end

  defp compare_columns(col1, col2) do
    IO.puts("Sorted Column 1: #{inspect(col1)}")
    IO.puts("Sorted Column 2: #{inspect(col2)}")

	differences = 0

    modified_number =
		Enum.zip(col1, col2)
		|> Enum.reduce(differences, fn {a, b}, acc ->
      #IO.puts("Differences: #{acc}")
      acc + abs(a-b)
    end)
	IO.puts("Modified number after comparisons: #{modified_number}")
  end

  defp multiply_by_frequency(col1, col2_frequencies) do
    similarity_score = Enum.map(col1, fn x ->
      frequency = Map.get(col2_frequencies, x, 0)

      if frequency > 0 do
        x * frequency
      else
        0
      end
    end)
    |> Enum.reduce(0, fn x, acc -> acc + x end)
    IO.puts("Similarity score: #{similarity_score}")
  end

  defp to_tuple([a, b]), do: {a, b}
  defp to_tuple(_), do: {:error, "Line does not have exactly two numbers"}
end

# Start processing input
FileProcessor.process_input_stream()
