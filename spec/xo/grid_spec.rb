require 'spec_helper'

module TTT

  describe Grid do

    it 'has 3 rows' do
      Grid::ROWS.must_equal 3
    end

    it 'has 3 columns' do
      Grid::COLS.must_equal 3
    end

    it 'contains all r, c where r is in {1, 2, 3} and c is in {1, 2, 3}' do
      (1..3).each do |r|
        (1..3).each do |c|
          Grid.contains?(r, c).must_equal true
        end
      end
    end

    it 'does not contain any r, c where either r is not in {1, 2, 3} or c is not in {1, 2, 3}' do
      [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4],
       [1, 0],                         [1, 4],
       [2, 0],                         [2, 4],
       [3, 0],                         [3, 4],
       [4, 0], [4, 1], [4, 2], [4, 3], [4, 4]].each do |pos|
        Grid.contains?(*pos).must_equal false
      end
    end

    let(:grid) { Grid.new }

    describe 'a new grid' do

      it 'is empty' do
        grid.empty?.must_equal true
      end
    end

    describe '#dup' do

      it 'creates a copy' do
        grid[1, 1] = X

        grid_copy = grid.dup
        grid_copy[1, 1] = O

        grid[1, 1].must_equal X
      end
    end

    describe '#empty?' do

      it 'returns false when at least one position has a token' do
        grid[1, 1] = X
        grid.empty?.must_equal false
      end
    end

    describe '#[]=' do

      it 'raises IndexError when a token is placed at a position it does not contain' do
        proc { grid[0, 0] = X }.must_raise IndexError
      end
    end

    describe '#[]' do

      it 'raises IndexError when given a position it does not contain' do
        proc { grid[4, 4] }.must_raise IndexError
      end
    end

    describe '#full?' do

      before do
        (1..3).each do |r|
          (1..3).each do |c|
            grid[r, c] = O
          end
        end
      end

      it 'returns true when every position has a token' do
        grid.full?.must_equal true
      end

      it 'returns false when at least one position does not have a token' do
        grid[1, 1] = :e
        grid.full?.must_equal false
      end
    end

    describe '#free?' do

      it 'returns true when no token is at the given position' do
        grid.free?(2, 2).must_equal true
      end

      it 'returns false when a token is at the given position' do
        grid[3, 1] = O
        grid.free?(3, 1).must_equal false
      end

      it 'raises IndexError when given a position the grid does not contain' do
        proc { grid.free?(0, 4) }.must_raise IndexError
      end
    end

    describe '#clear' do

      it 'empties the grid' do
        grid[1, 1] = X
        grid[1, 3] = O
        grid[3, 2] = X

        grid.clear

        grid.empty?.must_equal true
      end
    end

    describe '#each' do

      it "visits every position and yields a block that takes the position's row, column and value" do
        grid[1, 1] = O
        grid[2, 2] = X
        grid[3, 3] = O

        visited = {}

        grid.each do |r, c, val|
          # ensure that the value for the position is correct
          grid[r, c].must_equal val

          # keep track of every position we visit
          visited[[r, c]] = val
        end

        visited.keys.size.must_equal(Grid::ROWS * Grid::COLS)
      end
    end
  end
end
