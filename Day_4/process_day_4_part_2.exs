defmodule WordSearch do
  def find_word(grid) do
    first_letter = "A"
    word_length = 1
    IO.puts("Grid loaded:")
    IO.inspect(grid, label: "Grid")

    IO.puts("Looking for starting points for letter: #{first_letter}")

    # Find all starting points for the "A"
    starting_points = find_letter_positions(grid, first_letter)
    IO.inspect(starting_points, label: "Starting points")

    # Check each starting point in all directions
    Enum.reduce(starting_points, [], fn {x, y}, matches ->
      cond do
        match_word_in_direction?(grid, {x, y}, word_length) == true ->
          matches ++ [{x, y}]
        true -> matches
      end

    end)
    |> Enum.reduce(0, fn x, acc -> acc + 1 end)
  end

  defp find_letter_positions(grid, letter) do
    for x <- 0..(length(grid) - 1),
        y <- 0..(String.length(Enum.at(grid, x)) - 1),
        String.at(Enum.at(grid, x), y) == letter,
        do: {x, y}
  end

  defp match_word_in_direction?(grid, {x, y}, word_length) do
      nx = x + 1
      ny = y + 1
      mx = x - 1
      my = y - 1

      # mx, ny => TL
      # mx, my => BL
      # nx, my => BR
      # nx, ny => TR
      IO.puts("#{x}, #{y}")

      if valid_position?(grid, nx, ny) and valid_position?(grid, mx, my) and
         valid_position?(grid, mx, ny) and valid_position?(grid, nx, my) do
         (String.at(Enum.at(grid, mx), ny) == "M" and String.at(Enum.at(grid, mx), my) == "M" and
          String.at(Enum.at(grid, nx), my) == "S" and String.at(Enum.at(grid, nx), ny) == "S")
          or
          (String.at(Enum.at(grid, mx), ny) == "S" and String.at(Enum.at(grid, mx), my) == "S" and
           String.at(Enum.at(grid, nx), my) == "M" and String.at(Enum.at(grid, nx), ny) == "M")
          or
          (String.at(Enum.at(grid, mx), ny) == "M" and String.at(Enum.at(grid, mx), my) == "S" and
           String.at(Enum.at(grid, nx), my) == "S" and String.at(Enum.at(grid, nx), ny) == "M")
          or
          (String.at(Enum.at(grid, mx), ny) == "S" and String.at(Enum.at(grid, mx), my) == "M" and
           String.at(Enum.at(grid, nx), my) == "M" and String.at(Enum.at(grid, nx), ny) == "S")
      else
        false
      end
  end

  defp valid_position?(grid, x, y) do
    x >= 0 and y >= 0 and x < length(grid) and y < String.length(Enum.at(grid, x)) and x != nil and y != nil
  end
end

grid =
  IO.stream(:stdio, :line)
  |> Enum.map(&String.trim/1)

# M . S
# . A .
# M . S

matches = WordSearch.find_word(grid)

IO.inspect(matches, label: "Matches")
