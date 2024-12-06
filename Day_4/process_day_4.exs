defmodule WordSearch do
  def find_word(grid, word) do
    first_letter = String.first(word)
    word_length = String.length(word)

    IO.puts("Grid loaded:")
    IO.inspect(grid, label: "Grid")

    IO.puts("Looking for starting points for letter: #{first_letter}")

    # Find all starting points for the first letter
    starting_points = find_letter_positions(grid, first_letter)
    IO.inspect(starting_points, label: "Starting points")

    # Check each starting point in all directions
    Enum.reduce(starting_points, [], fn {x, y}, matches ->
      matches ++ check_directions(grid, {x, y}, word, word_length)
    end)
    |> Enum.reduce(0, fn x, acc -> acc + 1 end)
  end

  defp find_letter_positions(grid, letter) do
    for x <- 0..(length(grid) - 1),
        y <- 0..(String.length(Enum.at(grid, x)) - 1),
        String.at(Enum.at(grid, x), y) == letter,
        do: {x, y}
  end

  defp check_directions(grid, {x, y}, word, word_length) do
    directions = [
      {-1, 0}, {1, 0}, {0, -1}, {0, 1},  # Up, Down, Left, Right
      {-1, -1}, {-1, 1}, {1, -1}, {1, 1}  # Diagonals
    ]

    Enum.filter(directions, fn {dx, dy} ->
      output = match_word_in_direction?(grid, {x, y}, word, word_length, {dx, dy})

      output
    end)
    |> Enum.map(fn dir ->
      #IO.puts("Checking map!")
      #IO.puts("#{x}, #{y}, #{inspect(dir)}")
      {x, y, dir}
    end)
  end

  defp match_word_in_direction?(grid, {x, y}, word, word_length, {dx, dy}) do
    Enum.reduce_while(0..(word_length - 1), true, fn i, _ ->
      nx = x + (i * dx)
      ny = y + (i * dy)

      if valid_position?(grid, nx, ny) and String.at(Enum.at(grid, nx), ny) == String.at(word, i) do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  defp valid_position?(grid, x, y) do
    #IO.puts("#{x}, #{y}")
    x >= 0 and y >= 0 and x < length(grid) and y < String.length(Enum.at(grid, x))
  end
end

grid =
  IO.stream(:stdio, :line)
  |> Enum.map(&String.trim/1)

word = "XMAS"

IO.puts("Word to find: #{word}")
matches = WordSearch.find_word(grid, word)

IO.inspect(matches, label: "Matches")
