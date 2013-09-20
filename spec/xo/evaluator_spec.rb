require 'spec_helper'

module TTT

  describe Evaluator do

    describe 'analyze' do

      let (:grid) { Grid.new }

      it 'raises ArgumentError if x and o are the same' do
        proc { Evaluator.analyze(grid, :x, :x, :x) }.must_raise ArgumentError
      end

      it 'raises ArgumentError if player is neither the value of x nor o' do
        proc { Evaluator.analyze(grid, :z, :x, :o) }.must_raise ArgumentError
      end

      describe 'error statuses' do

        it 'returns too many moves ahead' do
          grid[1, 1] = grid[1, 2] = grid[1, 3] = :x
          grid[2, 1] = :o

          result = { status: :error, type: :too_many_moves_ahead }

          Evaluator.analyze(grid, :x).must_equal result
          Evaluator.analyze(grid, :o).must_equal result
        end

        it 'returns two winners' do
          grid[1, 1] = grid[1, 2] = grid[1, 3] = :x
          grid[2, 1] = grid[2, 2] = grid[2, 3] = :o

          result = { status: :error, type: :two_winners }

          Evaluator.analyze(grid, :x).must_equal result
          Evaluator.analyze(grid, :o).must_equal result
        end
      end

      describe 'game over statuses' do

        describe 'wins and losses' do

          it 'returns a win/loss in the first row' do
            grid[1, 1] = grid[1, 2] = grid[1, 3] = :x
            grid[2, 1] = grid[2, 2] = :o

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :row,
                index: 1,
                positions: [[1, 1], [1, 2], [1, 3]]
              }]
            }

            Evaluator.analyze(grid, :x).must_equal result

            result[:type] = :loser
            Evaluator.analyze(grid, :o).must_equal result
          end

          # TODO: Test the winners/losers in the other rows, the columns and the diagonals.
        end

        describe 'squashed' do

          it 'returns squashed' do
            grid[1, 1] = grid[1, 2] = grid[2, 3] = grid[3, 1] = grid[3, 3] = :x
            grid[1, 3] = grid[2, 1] = grid[2, 2] = grid[3, 2] = :o

            result = { status: :game_over, type: :squashed }

            Evaluator.analyze(grid, :x).must_equal result
            Evaluator.analyze(grid, :o).must_equal result
          end
        end
      end

      describe 'ok status' do

        it 'returns ok' do
          result = { status: :ok }

          Evaluator.analyze(grid, :x).must_equal result
          Evaluator.analyze(grid, :o).must_equal result

          grid[1, 1] = :x
          Evaluator.analyze(grid, :x).must_equal result
          Evaluator.analyze(grid, :o).must_equal result
        end
      end
    end
  end
end
