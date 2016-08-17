#!/usr/bin/env ruby

class GameOfLife

	class Grid
		# Ok because I keep fucking this up, the x coordinate is the ROW number
		# and the y coordinate is the COLUMN number. This might be backwards,
		# but at least now it will be consistently backwards.

		attr_accessor :size, :side, :grid_cells
		def initialize(side=8)
			@side = side
			@grid_cells = []
			side.times do
				row = []
				# Fun fact, if row is created outside of a loop, it seems to get added into
				# @grid_values by reference, not by value, and modifying one cell in a row
				# will modify that column's cell in ALL rows.
				side.times do
					row << GameOfLife::Cell.new
				end
				@grid_cells << row
			end
			@size = @grid_cells.size * @grid_cells.size
		end

		def fill(starting_values=nil)
			# This currently makes the naive assumption that starting_values has the same
			# dimensions as @grid_cells, which is not great.
			@grid_cells.each_index do |x|
				row = @grid_cells[x]
				row.each_index do |y|
					new_value = starting_values.nil? ? rand(2) == 1 : starting_values[x][y]
					set_cell_value(x, y, new_value)
				end
			end
		end

		def get_cell_value(x, y)
			return @grid_cells[x][y].state
		end

		def set_cell_value(x, y, value)
			@grid_cells[x][y].state = value
		end

		def print
			@grid_cells.each_index do |x|
				row = @grid_cells[x]
				row.each_index do |y|
					puts "#{x},#{y} ... #{get_cell_value(x,y)}"
				end
			end
		end

		def get_arrays
			# This returns the array of true/false values (not cells) for grid comparison in testing
			array = []
			@grid_cells.each_index do |x|
				new_row = []
				row = @grid_cells[x]
				row.each_index do |y|
					new_row << get_cell_value(x, y)
				end
				array << new_row
			end
			return array
		end

		# These four methods set up the "infinite" grid that really just loops around.
		def get_index_to_right(x, y)
			return y == (@side - 1) ? 0 : y + 1
		end

		def get_index_to_left(x, y)
			return y == 0 ? (@side - 1) : y - 1
		end

		def get_index_above(x, y)
			return x == 0 ? (@side - 1) : x - 1
		end

		def get_index_below(x, y)
			return x == (@side - 1) ? 0 : x + 1
		end

		def count_alive_neighbors(x, y)
			# There is maybe a prettier way of doing this.
			alive_neighbors = 0
			alive_neighbors += 1 if get_cell_value(get_index_above(x, y), get_index_to_left(x, y))
			alive_neighbors += 1 if get_cell_value(get_index_above(x, y), y)
			alive_neighbors += 1 if get_cell_value(get_index_above(x, y), get_index_to_right(x, y))
			alive_neighbors += 1 if get_cell_value(x, get_index_to_left(x, y))
			alive_neighbors += 1 if get_cell_value(x, get_index_to_right(x, y))
			alive_neighbors += 1 if get_cell_value(get_index_below(x, y), get_index_to_left(x, y))
			alive_neighbors += 1 if get_cell_value(get_index_below(x, y), y)
			alive_neighbors += 1 if get_cell_value(get_index_below(x, y), get_index_to_right(x, y))
			return alive_neighbors
		end

		def get_next_cell_state(x, y)
			live_neighbors = count_alive_neighbors(x, y)
			if get_cell_value(x, y) and live_neighbors < 2
				return false
			elsif get_cell_value(x, y) and live_neighbors <= 3
				return true
			elsif get_cell_value(x, y) and live_neighbors >= 4
				return false
			elsif (not get_cell_value(x, y)) and live_neighbors == 3
				return true
			else
				return false
			end
		end

	end


	class Game

		def get_next_state(grid)
			new_grid = Grid.new(5)

			grid.grid_cells.each_index do |x|
				row = grid.grid_cells[x]
				row.each_index do |y|
					new_grid.set_cell_value(x, y, grid.get_next_cell_state(x, y))
				end
			end

			return new_grid
		end

	end


	class Cell

		attr_accessor :state
		def initialize(state=nil)
			@state = state
		end
	end

end