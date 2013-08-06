require_relative 'spec_helper'
require_relative '../lib/xo/board'

module TTT

  describe Board do

    before do
      @board = Board.new
    end

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
      [[0, 0], [0, 4], [4, 0], [4, 4]].each do |cell|
        Board.contains?(*cell).must_equal false
      end
    end

    it 'starts off empty' do
      @board.empty?.must_equal true
    end

    it 'starts off not full' do
      @board.full?.must_equal false
    end

    it 'is not empty when at least one token is placed on the board' do
      @board[1, 1] = :x
      @board.empty?.must_equal false

      @board[1, 1] = :o
      @board.empty?.must_equal false
    end

    it 'raises IndexError when you try to place a value at a position that it does not contain' do
      proc { @board[0, 0] = :anything }.must_raise IndexError
    end

    it 'raises IndexError when you try to query a position that it does not contain' do
      proc { @board[0, 4] }.must_raise IndexError
    end

    it 'gets updated with the value you place on it' do
      @board[2, 1] = :x
      @board[2, 1].must_equal :x

      @board[2, 2] = :o
      @board[2, 2].must_equal :o

      @board[2, 3] = :anything_else
      @board[2, 3].must_equal :anything_else
    end

    describe '#full?' do

      before do
        (1..3).each do |r|
          (1..3).each do |c|
            @board[r, c] = :x
          end
        end
      end

      it 'returns true when every position has a token' do
        @board.full?.must_equal true
      end

      it 'returns false when at least one position does not have a token' do
        @board[1, 1] = :not_a_token
        @board.full?.must_equal false
      end
    end

    describe '#free?' do

      it 'returns true when a non-token is placed at the position' do
        @board[3, 1] = :anything_that_is_not_x_or_o
        @board.free?(3, 1).must_equal true
      end

      it 'returns false when :x is placed at the position' do
        @board[3, 2] = :x
        @board.free?(3, 2).must_equal false
      end

      it 'returns false when :o is placed at the position' do
        @board[3, 3] = :o
        @board.free?(3, 3).must_equal false
      end
    end

    describe '#clear' do

      it 'removes all tokens' do
        @board[1, 1] = :x
        @board[1, 2] = :o
        @board[1, 3] = :x

        @board.clear

        @board.empty?.must_equal true
      end
    end

    describe '#each' do

      it "visits every position and yields a block that takes the position's row, column and value" do
        visited = {}

        @board.each do |r, c, val|
          # ensure that the value for the position is correct
          @board[r, c].must_equal val

          # keep track of every position we visit
          visited[[r, c]] = val
        end

        visited.keys.size.must_equal(Board::ROWS * Board::COLS)
      end
    end
  end
end
