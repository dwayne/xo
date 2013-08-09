require_relative 'spec_helper'
require 'xo/board'

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

    describe 'Board#token?' do

      it 'returns true for :x' do
        Board.is_token?(:x).must_equal true
      end

      it 'returns true for :o' do
        Board.is_token?(:o).must_equal true
      end

      it 'return false if the argument is neither :x nor :o' do
        Board.is_token?(:neither_x_nor_o).must_equal false
      end
    end

    describe 'Board#other_token' do

      it 'returns :x when given :o' do
        Board.other_token(:x).must_equal :o
      end

      it 'returns :o when given :x' do
        Board.other_token(:o).must_equal :x
      end

      it "returns whatever it was given when it's not an :x or an :o" do
        Board.other_token(:neither_x_nor_o).must_equal :neither_x_nor_o
      end
    end

    let(:board) { Board.new }

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

    describe '#state' do

      describe 'winning states' do

        describe 'when :x wins in the 1st row' do

          it 'returns that :x won together with the winning position' do
            board[1, 1] = board[1, 2] = board[1, 3] = :x
            board[2, 1] = board[2, 2] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :row, index: 1 }]
            )
          end
        end

        describe 'when :x wins in the 2nd row' do

          it 'returns that :x won together with the winning position' do
            board[2, 1] = board[2, 2] = board[2, 3] = :x
            board[1, 1] = board[1, 2] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :row, index: 2 }]
            )
          end
        end

        describe 'when :x wins in the 3rd row' do

          it 'returns that :x won together with the winning position' do
            board[3, 1] = board[3, 2] = board[3, 3] = :x
            board[2, 1] = board[2, 2] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :row, index: 3 }]
            )
          end
        end

        describe 'when :x wins in the 1st column' do

          it 'returns that :x won together with the winning position' do
            board[1, 1] = board[2, 1] = board[3, 1] = :x
            board[1, 2] = board[2, 2] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :column, index: 1 }]
            )
          end
        end

        describe 'when :x wins in the 2nd column' do

          it 'returns that :x won together with the winning position' do
            board[1, 2] = board[2, 2] = board[3, 2] = :x
            board[1, 1] = board[2, 1] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :column, index: 2 }]
            )
          end
        end

        describe 'when :x wins in the 3rd column' do

          it 'returns that :x won together with the winning position' do
            board[1, 3] = board[2, 3] = board[3, 3] = :x
            board[1, 2] = board[2, 2] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :column, index: 3 }]
            )
          end
        end

        describe 'when :x wins in the 1st diagonal' do

          it 'returns that :x won together with the winning position' do
            board[1, 1] = board[2, 2] = board[3, 3] = :x
            board[1, 2] = board[2, 1] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :diagonal, index: 1 }]
            )
          end
        end

        describe 'when :x wins in the 2nd diagonal' do

          it 'returns that :x won together with the winning position' do
            board[1, 3] = board[2, 2] = board[3, 1] = :x
            board[1, 2] = board[2, 1] = :o

            board.state(:x).must_equal(
              state: :game_over,
              reason: :winner,
              details: [{ where: :diagonal, index: 2 }]
            )
          end
        end

        describe 'when :x wins in two different ways' do

          it 'returns that :x won together with both winning positions' do
            board[1, 1] = board[1, 2] = board[1, 3] = board[2, 1] = board[3, 1] = :x
            board[2, 2] = board[2, 3] = board[3, 2] = board[3, 3] = :o

            result = board.state(:x)

            result[:state].must_equal :game_over
            result[:reason].must_equal :winner

            result[:details].size.must_equal 2
            result[:details].include? where: :row, index: 1
            result[:details].include? where: :column, index: 1
          end
        end
      end

      describe 'when :o loses to :x in the 1st row' do

        it 'returns that :o lost together with the winning position of :x' do
          board[1, 1] = board[1, 2] = board[1, 3] = :x
          board[2, 1] = board[2, 3] = :o

          board.state(:o).must_equal(
            state: :game_over,
            reason: :loser,
            details: [{ where: :row, index: 1 }]
          )
        end
      end

      describe 'when squashed' do

        it 'returns that it is squashed' do
          board[1, 1] = board[1, 3] = board[2, 2] = board[3, 2] = :x
          board[1, 2] = board[2, 1] = board[2, 3] = board[3, 1] = board[3, 3] = :o

          board.state(:x).must_equal(
            state: :game_over,
            reason: :squashed
          )
        end
      end

      describe 'when nothing significant happens' do

        it 'returns that everything is normal' do
          board.state(:x).must_equal(state: :normal)
        end
      end

      it 'raises ArgumentError when the argument is neither :x nor :o' do
        proc { board.state(:neither_x_nor_o) }.must_raise ArgumentError
      end

      describe 'invalid configurations' do

        it 'raises TooManyMovesAheadError when :x is ahead of :o by 2 moves' do
          board[1, 1] = board[1, 2] = :x

          proc { board.state(:x) }.must_raise TooManyMovesAheadError
        end

        it 'raises TooManyMovesAheadError when :x is ahead of :o by more than 2 moves' do
          board[1, 1] = board[1, 2] = board[1, 3] = board[3, 1] = board[3, 2] = board[3, 3] = :x
          board[2, 1] = board[2, 2] = :o

          proc { board.state(:o) }.must_raise TooManyMovesAheadError
        end

        it 'raises TooManyMovesAheadError when :o is ahead of :x by 2 moves' do
          board[2, 1] = board[2, 2] = board[2, 3] = :o
          board[3, 1] = :x

          proc { board.state(:x) }.must_raise TooManyMovesAheadError
        end

        it 'raises TooManyMovesAheadError when :o is ahead of :x by more than 2 moves' do
          board[1, 1] = board[2, 1] = board[2, 3] = board[3, 1] = board[3, 3] = :x
          board[2, 2] = :o

          proc { board.state(:o) }.must_raise TooManyMovesAheadError
        end

        it 'raise TwoWinnersError when both :x and :o have winning positions' do
          board[1, 1] = board[1, 2] = board[1, 3] = :x
          board[2, 1] = board[2, 2] = board[2, 3] = :o

          proc { board.state(:x) }.must_raise TwoWinnersError
        end
      end
    end
  end
end
