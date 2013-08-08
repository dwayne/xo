require_relative 'spec_helper'
require_relative '../lib/xo/board'

module TTT

  describe Board do

    it 'has 3 rows' do
      Board::ROWS.must_equal 3
    end

    it 'has 3 columns' do
      Board::COLS.must_equal 3
    end

    it 'contains all r, c where r is in {1, 2, 3} and c is in {1, 2, 3}' do
      (1..3).each do |r|
        (1..3).each do |c|
          Board.contains?(r, c).must_equal true
        end
      end
    end

    it 'does not contain any r, c where either r is not in {1, 2, 3} or c is not in {1, 2, 3}' do
      [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4],
       [1, 0],                         [1, 4],
       [2, 0],                         [2, 4],
       [3, 0],                         [3, 4],
       [4, 0], [4, 1], [4, 2], [4, 3], [4, 4]].each do |cell|
        Board.contains?(*cell).must_equal false
      end
    end

    let :board do
      Board.new
    end

    describe '#empty?' do

      it 'returns true for a new board' do
        board.empty?.must_equal true
      end

      it 'returns false when an :x is on the board' do
        board[1, 1] = :x
        board.empty?.must_equal false
      end

      it 'returns false when an :o is on the board' do
        board[1, 2] = :o
        board.empty?.must_equal false
      end
    end

    describe '#[]' do

      it 'raises IndexError when queried with an out of bounds position' do
        proc { board[0, 0] }.must_raise IndexError
      end
    end

    describe '#[]=' do

      it 'raises IndexError when a value is placed at an out of bounds position' do
        proc { board[1, 0] = :anything }.must_raise IndexError
      end
    end

    describe '#full?' do

      before do
        (1..3).each do |r|
          (1..3).each do |c|
            board[r, c] = :x
          end
        end
      end

      it 'returns true when every position is occupied' do
        board.full?.must_equal true
      end

      it 'returns false when at least one position is not occupied' do
        board[1, 1] = :not_occupied
        board.full?.must_equal false
      end
    end

    describe '#free?' do

      it 'returns true when neither :x nor :o is at the given position' do
        board.free?(3, 1).must_equal true
      end

      it 'returns false when :x occupies the position' do
        board[3, 2] = :x
        board.free?(3, 2).must_equal false
      end

      it 'returns false when :o occupies the position' do
        board[3, 3] = :o
        board.free?(3, 3).must_equal false
      end
    end

    describe '#clear' do

      it 'removes all :x and :o' do
        board[1, 1] = :x
        board[1, 2] = :o
        board[1, 3] = :x

        board.clear

        board.empty?.must_equal true
      end
    end

    describe '#each' do

      it "visits every position and yields a block that takes the position's row, column and value" do
        visited = {}

        board.each do |r, c, val|
          # ensure that the value for the position is correct
          board[r, c].must_equal val

          # keep track of every position we visit
          visited[[r, c]] = val
        end

        visited.keys.size.must_equal(Board::ROWS * Board::COLS)
      end
    end
  end
end
