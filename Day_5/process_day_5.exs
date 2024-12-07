defmodule FileProcessor do
  def process_input_stream() do

    # Page ordering rules:
    {col1, col2} =
    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.take_while(&(&1 != ""))  # Process until an empty line is found
    |> Stream.map(&parse_line/1)
    |> Enum.reduce({[], []}, fn
      {:error, msg}, acc ->
          IO.puts("Error: #{msg}")
          acc

        {a, b}, {list1, list2} ->
          {[a | list1], [b | list2]}
      end)
    IO.puts("page_ordering_rules: #{inspect(Enum.zip(col1, col2), charlists: :as_lists)}")

    # Page number updates:
    page_number_updates =
      IO.stream(:stdio, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split(&1, ",")) # Split on ,
      |> Enum.map(fn x ->
        z = Enum.map(x, fn y ->
          String.to_integer(y)
        end)
        IO.puts("z: #{inspect(z, charlists: :as_lists)}")
        z
      end)
    IO.puts("page_number_updates: #{inspect(page_number_updates, charlists: :as_lists)}")

    # Create a hash map, mapping PageThatComesBefore -> [ThesePagesAfterward, ... n]
    ordering_rules_map =
      Enum.zip(col1, col2)
      |> Enum.reduce(%{}, fn {x, y}, acc ->
        Map.update(acc, y, [x], fn existing_value -> existing_value ++ [x] end)
      end)
    IO.puts("ordering_rules_map: #{inspect(ordering_rules_map, charlists: :as_lists)}")

    # For each page number update list, determine if all
    correctly_printed_updates = page_number_updates
    |> Enum.filter(fn updates ->
      IO.puts("\nCurrent updates: #{inspect(updates, charlists: :as_lists)}")
      outputs = updates
      |> Enum.map(fn current ->
        all_before_current = updates
        |> Enum.take_while(fn x -> x != current end)

        existing_rules = case ordering_rules_map[current] do
          nil -> []
          rules -> Enum.filter(rules, fn rule ->
            if rule in updates do
              rule
            else
              nil
            end
          end)
        end

        [current, all_before_current || [], existing_rules || []]
      end)

      correct_updates = outputs
      |> Enum.all?(fn [current, all_before_current, existing_rules] ->
        IO.puts("\ncurrent: #{current}, all_before_current: #{inspect(all_before_current, charlists: :as_lists)}, existing_rules: #{inspect(existing_rules, charlists: :as_lists)}")
        if length(existing_rules) == 0 do
          true
        end
        #IO.puts("current: #{current}, rules_for_current: #{inspect(rules_for_current, charlists: :as_lists)}, all_before_current: #{inspect(all_before_current, charlists: :as_lists)}")
        #IO.puts("rules_for_current == nil: #{inspect(rules_for_current == nil)}")
        Enum.all?(existing_rules, fn existing_rule ->
          IO.puts("existing_rule '#{inspect(existing_rule)}'")
          cond do
            existing_rule in all_before_current -> true
            true -> false
          end
        end)
      end)
      IO.puts("outputs: #{inspect(outputs, charlists: :as_lists)}")
      IO.puts("correct_updates: #{inspect(correct_updates, charlists: :as_lists)}")
      correct_updates
    end)

    IO.puts("#{inspect(correctly_printed_updates, charlists: :as_lists)}")

    sum_of_middle_numbers = correctly_printed_updates
    |> Enum.map(fn middle ->
      Enum.at(middle, floor(length(middle) / 2))
    end)
    |> Enum.sum()

    IO.puts("Sum of middles: #{sum_of_middle_numbers}")

  end

  defp parse_line(line) do
    output = line
    |> String.split("|")
    |> Enum.map(&String.to_integer/1)
    |> to_tuple()
    IO.puts("#{inspect(output, charlists: :as_lists)}")
    output
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
