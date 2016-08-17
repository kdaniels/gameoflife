#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative 'gameoflife'

class GameOfLifeTest < Minitest::Test

	def setup
		@small_grid = [ [true, false], [false, false] ]
		@medium_grid = [ [true, false, false], [false, true, true], [true, false, true]]
		@large_grid = [
			[false, false, false, false, false],
			[false, false, false, true, false],
			[false, true, false, true, false],
			[false, false, false, true, false],
			[false, true, true, true, true]
		]
		@next_large_grid = [
			[false, false, false, false, true],
			[false, false, true, false, false],
			[false, false, false, true, true],
			[true, true, false, false, false],
			[false, false, true, true, true]
		]
	end

	def test_create_empty_grid
		grid = GameOfLife::Grid.new
		assert_equal(64, grid.size)
	end

	def test_create_smaller_grid
		grid = GameOfLife::Grid.new(4)
		assert_equal(16, grid.size)
	end

	def test_fill_individual_grid_cell
		grid = GameOfLife::Grid.new(4)
		grid.set_cell_value(0, 1, true)
		assert_equal(true, grid.get_cell_value(0, 1))
		assert_equal(nil, grid.get_cell_value(1, 1))
	end

	def test_fill_grid_random
		grid = GameOfLife::Grid.new
		grid.fill
		assert_includes([true, false], grid.get_cell_value(0,0))
	end

	def test_fill_grid_preset
		grid = GameOfLife::Grid.new(2)
		grid.fill(@small_grid)
		assert_equal(true, grid.get_cell_value(0,0))
		assert_equal(false, grid.get_cell_value(0,1))
		assert_equal(false, grid.get_cell_value(1,0))
		assert_equal(false, grid.get_cell_value(1,1))
	end

	def test_get_cell_to_right
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		right_index = grid.get_index_to_right(1, 1)
		assert_equal(2, right_index)
		assert_equal(true, grid.get_cell_value(1, right_index))
	end

	def test_get_cell_to_right_edge
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		right_index = grid.get_index_to_right(0, 2)
		assert_equal(0, right_index)
		assert_equal(true, grid.get_cell_value(0, right_index))
	end

	def test_get_cell_to_left
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		left_index = grid.get_index_to_left(0, 1)
		assert_equal(0, left_index)
		assert_equal(true, grid.get_cell_value(0, left_index))
	end

	def test_get_cell_to_left_edge
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		left_index = grid.get_index_to_left(1, 0)
		assert_equal(2, left_index)
		assert_equal(true, grid.get_cell_value(1, left_index))
	end

	def test_get_cell_above
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		above_index = grid.get_index_above(1, 1)
		assert_equal(0, above_index)
		assert_equal(false, grid.get_cell_value(above_index, 1))
	end

	def test_get_cell_above_edge
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		above_index = grid.get_index_above(0, 0)
		assert_equal(2, above_index)
		assert_equal(true, grid.get_cell_value(above_index, 0))
	end

	def test_get_cell_below
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		below_index = grid.get_index_below(0, 2)
		assert_equal(1, below_index)
		assert_equal(true, grid.get_cell_value(below_index, 2))
	end

	def test_get_cell_below_edge
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		below_index = grid.get_index_below(2, 1)
		assert_equal(0, below_index)
		assert_equal(false, grid.get_cell_value(below_index, 1))
	end

	# Next we can test getting the live neighbor count
	def test_count_alive_neighbors
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		alive_neighbors = grid.count_alive_neighbors(1, 1)
		assert_equal(4, alive_neighbors)
	end

	def test_count_alive_neighbors_edge
		grid = GameOfLife::Grid.new(3)
		grid.fill(@medium_grid)
		alive_neighbors = grid.count_alive_neighbors(0, 2)
		assert_equal(5, alive_neighbors)
	end

	# Wooo, now we can start testing that the next tick rules work!
	def test_underpopulated_cell_dies
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		next_state = grid.get_next_cell_state(2, 1)
		assert_equal(false, next_state)
	end

	def test_happy_cell_lives
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		next_state = grid.get_next_cell_state(2, 3)
		assert_equal(true, next_state)
	end

	def test_overpopulated_cell_dies
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		next_state = grid.get_next_cell_state(3, 3)
		assert_equal(false, next_state)
	end

	def test_cell_comes_back
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		next_state = grid.get_next_cell_state(3, 1)
		assert_equal(true, next_state)
	end

	def test_cell_stays_dead
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		next_state = grid.get_next_cell_state(3, 2)
		assert_equal(false, next_state)
	end

	# Woooooooo run one full tick!
	def test_grid_next_tick
		game = GameOfLife::Game.new
		grid = GameOfLife::Grid.new(5)
		grid.fill(@large_grid)
		new_grid = game.get_next_state(grid)
		assert_equal(@next_large_grid, new_grid.get_arrays)
	end

end
