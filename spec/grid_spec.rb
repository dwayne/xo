require 'spec_helper'

def for_each_cell
  [1, 2, 3].each { |r| [1, 2, 3].each { |c| yield r, c } }
end

describe TicTacToe::Grid do

  describe "it's dimensions" do
    it "must have 3 rows" do
      TicTacToe::Grid::ROWS.must_equal 3
    end

    it "must have 3 columns" do
      TicTacToe::Grid::COLS.must_equal 3
    end
  end

  describe "it's layout" do
    #     1   2   3
    # 1     |   |
    #    ---+---+---
    # 2     |   |
    #    ---+---+---
    # 3     |   |
    it "must contain the cells for which the row and column values are both in [1..3]" do
      for_each_cell { |r, c| TicTacToe::Grid.contains?(r, c).must_equal true }
    end

    it "must not contain any cells for which either the row or column value is not in [1..3]" do
      # unfortunately this requirement cannot be tested completely
      # however, the tests below should be sufficient to ensure
      # that an implementation doesn't have off by one errors
      [0, 1, 2, 3, 4].each { |r| TicTacToe::Grid.contains?(r, 0).must_equal false }
      [0, 1, 2, 3, 4].each { |r| TicTacToe::Grid.contains?(r, 4).must_equal false }
      [0, 1, 2, 3, 4].each { |c| TicTacToe::Grid.contains?(0, c).must_equal false }
      [0, 1, 2, 3, 4].each { |c| TicTacToe::Grid.contains?(4, c).must_equal false }
    end
  end

  describe "how it works" do
    before do
      @grid = TicTacToe::Grid.new
    end

    it "initializes each cell to the empty token" do
      for_each_cell { |r, c| @grid.empty?(r, c).must_equal true }
    end

    it "returns the same token it put into the cell" do
      for_each_cell do |r, c|
        @grid.putx(r, c)[r, c].must_equal :x
        @grid.puto(r, c)[r, c].must_equal :o
      end
    end

    it "fails with an IndexError exception whenever an out of bounds cell is accessed" do
      lambda { @grid[0, 0] }.must_raise IndexError
    end

    it "can clear individual cells" do
      for_each_cell do |r, c|
        @grid.putx(r, c).clear(r, c).empty?(r, c).must_equal true
        @grid.puto(r, c).clear(r, c).empty?(r, c).must_equal true
      end
    end

    it "can clear all cells at once" do
      # fill the cells with x's and o's
      for_each_cell { |r, c| @grid.putx(r, c) }
      @grid.puto 1, 1
      @grid.puto 1, 3
      @grid.puto 3, 1
      @grid.puto 3, 3

      @grid.clear_all

      for_each_cell { |r, c| @grid.empty?(r, c).must_equal true }
    end

    it "is cloneable" do
      @grid.putx 1, 1
      @grid.puto 1, 2

      grid_clone = @grid.clone
      grid_clone.clear_all

      @grid[1, 1].must_equal :x
      @grid[1, 2].must_equal :o

      grid_clone.putx 1, 3

      @grid.empty?(1, 3).must_equal true
    end

    describe "how status works" do
      # TODO
    end
  end
end
