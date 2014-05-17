require 'spec_helper'

module XO

  describe Grid do

    let(:grid) { Grid.new }

    it "defines X" do
      Grid::X.must_equal :x
    end

    it "defines O" do
      Grid::O.must_equal :o
    end

    it "defines EMPTY" do
      Grid::EMPTY.must_equal :e
    end

    it "has 3 rows" do
      Grid::ROWS.must_equal 3
    end

    it "has 3 columns" do
      Grid::COLS.must_equal 3
    end

    it "has 9 positions" do
      Grid::N.must_equal 9
    end

    describe ".contains?" do

      it "contains all r, c where r is in {1, 2, 3} and c is in {1, 2, 3}" do
        (1..3).each do |r|
          (1..3).each do |c|
            Grid.contains?(r, c).must_equal true
          end
        end
      end

      it "does not contain any r, c where either r is not in {1, 2, 3} or c is not in {1, 2, 3}" do
        [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4],
         [1, 0],                         [1, 4],
         [2, 0],                         [2, 4],
         [3, 0],                         [3, 4],
         [4, 0], [4, 1], [4, 2], [4, 3], [4, 4]].each do |pos|
          Grid.contains?(*pos).must_equal false
        end
      end
    end

    describe ".is_token?" do

      it "returns true for an X" do
        Grid.is_token?(Grid::X).must_equal true
      end

      it "returns true for an O" do
        Grid.is_token?(Grid::O).must_equal true
      end

      it "returns false otherwise" do
        [nil, :e, '', ' '].each do |val|
          Grid.is_token?(val).must_equal false
        end
      end
    end

    describe ".other_token" do

      it "returns O given X" do
        Grid.other_token(Grid::X).must_equal Grid::O
      end

      it "returns X given O" do
        Grid.other_token(Grid::O).must_equal Grid::X
      end

      it "returns the same value it was given otherwise" do
        Grid.other_token(:something_else).must_equal :something_else
      end
    end

    describe ".new" do

      it "is returns an empty grid when given no arguments" do
        grid.empty?.must_equal true
      end

      it "can create a grid from a string" do
        grid = Grid.new('xox o')

        grid[1, 1].must_equal Grid::X
        grid[1, 2].must_equal Grid::O
        grid[1, 3].must_equal Grid::X
        grid[2, 2].must_equal Grid::O

        [[2, 1], [2, 3], [3, 1], [3, 2], [3, 3]].each do |pos|
          grid.open?(*pos).must_equal true
        end
      end

      it "only considers the first 9 characters" do
        grid = Grid.new('         xoxoxoxox')

        grid.empty?.must_equal true
      end

      it "can create a grid given exactly 9 characters" do
        grid = Grid.new('xoxoxoxox')

        grid.full?.must_equal true
      end
    end

    describe "#dup" do

      it "creates a copy" do
        grid[1, 1] = Grid::X

        grid_copy = grid.dup
        grid_copy[1, 1] = Grid::O

        grid_copy[1, 1].must_equal Grid::O
        grid[1, 1].must_equal Grid::X
      end
    end

    describe "#empty?" do

      it "returns false when at least one position has a token" do
        grid[1, 2] = Grid::X
        grid.empty?.must_equal false
      end

      it "returns true otherwise" do
        grid.empty?.must_equal true
      end
    end

    describe "#full?" do

      before do
        (1..3).each do |r|
          (1..3).each do |c|
            grid[r, c] = Grid::O
          end
        end
      end

      it "returns true when every position has a token" do
        grid.full?.must_equal true
      end

      it "returns false when at least one position doesn't have a token" do
        grid[1, 3] = Grid::EMPTY
        grid.full?.must_equal false
      end
    end

    describe "#[]=" do

      it "sets a position to X, O or EMPTY" do
        grid[2, 1] = Grid::X
        grid[2, 1].must_equal Grid::X

        grid[2, 2] = Grid::O
        grid[2, 2].must_equal Grid::O

        grid[2, 3] = :anything_else
        grid[2, 3].must_equal Grid::EMPTY
      end

      it "raises IndexError when the position is off the grid" do
        proc { grid[0, 0] = Grid::X }.must_raise IndexError
      end
    end

    describe "#[]" do

      it "raises IndexError when the position is off the grid" do
        proc { grid[4, 4] }.must_raise IndexError
      end
    end

    describe "#open?" do

      it "returns true when no token is at the given position" do
        grid.open?(2, 2).must_equal true
      end

      it "returns false when a token is at the given position" do
        grid[2, 3] = Grid::O
        grid.open?(2, 3).must_equal false
      end

      it "raises IndexError when the position is off the grid" do
        proc { grid.open?(0, 4) }.must_raise IndexError
      end
    end

    describe "#clear" do

      it "removes all tokens from the grid" do
        grid[3, 1] = Grid::X
        grid[3, 2] = Grid::O
        grid[3, 3] = Grid::X

        grid.clear

        grid.empty?.must_equal true
      end
    end

    describe "#each" do

      it "visits every position and yields a block that takes the position's row, column and value" do
        grid[1, 1] = Grid::O
        grid[2, 2] = Grid::X
        grid[3, 3] = Grid::O

        visited = {}

        grid.each do |r, c, val|
          # ensure that the position (r, c) is contained within the grid and
          # ensure that the value at the position is correct
          grid[r, c].must_equal val

          # keep track of every position we visit
          visited[[r, c]] = val
        end

        visited.keys.size.must_equal(Grid::ROWS * Grid::COLS)
      end
    end

    describe "#each_open" do

      it "visits every open position and yields a block that takes the position's row and column" do
        grid[1, 3] = Grid::X
        grid[2, 2] = Grid::O
        grid[3, 1] = Grid::X

        visited = {}

        grid.each_open do |r, c|
          visited[[r, c]] = true
        end

        visited.keys.size.must_equal(Grid::ROWS * Grid::COLS - 3)

        [[1, 1], [1, 2], [2, 1], [2, 3], [3, 2], [3, 3]].each do |pos|
          visited.key?(pos)
        end
      end
    end

    describe "#inspect" do

      it "returns a single line string representation of the grid" do
        grid[1, 1] = grid[1, 3] = Grid::X
        grid[1, 2] = grid[3, 3] = Grid::O

        grid.inspect.must_equal "xox     o"
      end
    end

    describe "#to_s" do

      it "returns a multiline string representation of the grid" do
        grid[2, 1] = grid[2, 3] = Grid::X
        grid[1, 2] = grid[2, 2] = Grid::O

        grid.to_s.must_equal [
          "   | o |   ",
          "---+---+---",
          " x | o | x ",
          "---+---+---",
          "   |   |   "
        ].join("\n")
      end
    end
  end
end
