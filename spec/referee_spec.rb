require_relative 'spec_helper'
require_relative '../lib/xo/board'
require_relative '../lib/xo/referee'

module TTT

  describe Referee do

    before do
      @board = Board.new
      @referee = Referee.new(@board)
    end

    describe '#check_status' do

      it 'raises ArgumentError when its argument is neither :x nor :o' do
        proc { @referee.check_status(:neither_x_nor_o) }.must_raise ArgumentError
      end

      describe 'legal configurations' do

        it 'returns :game_still_in_progress at the start' do
          status = @referee.check_status(:x)
          status[:event].must_equal :game_still_in_progress

          status = @referee.check_status(:o)
          status[:event].must_equal :game_still_in_progress
        end

        it 'returns :game_still_in_progress when there are no winners and the game is not squashed' do
          @board[1, 1] = :o
          @board[1, 2] = :x
          @board[2, 1] = :o
          @board[2, 2] = :x

          status = @referee.check_status(:x)
          status[:event].must_equal :game_still_in_progress

          status = @referee.check_status(:o)
          status[:event].must_equal :game_still_in_progress
        end

        describe 'winning positions' do

          it 'returns a win for :x in the first row when :x has the first row' do
            @board[1, 1] = @board[1, 2] = @board[1, 3] = :x
            @board[2, 1] = @board[2, 2] = :o

            status = @referee.check_status(:x)
            status[:message][:type].must_equal :winner

            detail = status[:message][:details].first
            detail[:where].must_equal :row
            detail[:index].must_equal 1
          end

          it 'returns a win for :x in the second row when :x has the second row' do
            @board[2, 1] = @board[2, 2] = @board[2, 3] = :x
            @board[1, 1] = @board[1, 2] = :o

            status = @referee.check_status(:x)
            status[:message][:type].must_equal :winner

            detail = status[:message][:details].first
            detail[:where].must_equal :row
            detail[:index].must_equal 2
          end

          it 'returns a win for :x in the third row when :x has the third row' do
            @board[3, 1] = @board[3, 2] = @board[3, 3] = :x
            @board[2, 1] = @board[2, 2] = :o

            status = @referee.check_status(:x)
            status[:message][:type].must_equal :winner

            detail = status[:message][:details].first
            detail[:where].must_equal :row
            detail[:index].must_equal 3
          end
        end
      end

      describe 'illegal configurations' do

        it 'raises IllegalBoardConfiguration when :x is ahead of :o by 2 moves' do
          @board[2, 2] = :o
          @board[1, 1] = :x
          @board[1, 2] = :x
          @board[1, 3] = :x

          proc { @referee.check_status(:x) }.must_raise IllegalBoardConfiguration
          proc { @referee.check_status(:o) }.must_raise IllegalBoardConfiguration
        end

        it 'raises IllegalBoardConfiguration when :o is ahead of :x by 3 moves' do
          @board[1, 1] = :o
          @board[2, 2] = :o
          @board[3, 3] = :o

          proc { @referee.check_status(:x) }.must_raise IllegalBoardConfiguration
          proc { @referee.check_status(:o) }.must_raise IllegalBoardConfiguration
        end

        it 'raises IllegalBoardConfiguration when both :x and :o have winning positions' do
          @board[1, 1] = :o
          @board[1, 2] = :o
          @board[1, 3] = :o
          @board[2, 1] = :x
          @board[2, 2] = :x
          @board[2, 3] = :x

          proc { @referee.check_status(:x) }.must_raise IllegalBoardConfiguration
          proc { @referee.check_status(:o) }.must_raise IllegalBoardConfiguration
        end
      end
    end
  end
end
