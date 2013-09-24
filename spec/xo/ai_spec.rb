require 'spec_helper'

module TTT

   describe AI do

    describe 'minimax' do

      let(:grid) { Grid.new }

      describe 'immediate wins' do

        it 'should return (1, 3)' do
          grid[1, 1] = grid[1, 2] = :x
          grid[2, 1] = grid[2, 2] = :o

          moves = AI.minimax(grid, :x)

          moves.size.must_equal 1
          [moves[0].row, moves[0].column].must_equal [1, 3]
        end

        it 'should return (1, 3), (3, 2) and (3, 3)' do
          grid[2, 1] = grid[2, 3] = grid[3, 1] = :x
          grid[1, 1] = grid[1, 2] = grid[2, 2] = :o

          moves = AI.minimax(grid, :o)

          moves.size.must_equal 3
          [moves[0].row, moves[0].column].must_equal [1, 3]
          [moves[1].row, moves[1].column].must_equal [3, 2]
          [moves[2].row, moves[2].column].must_equal [3, 3]
        end
      end

      describe 'blocking moves' do

        it 'should return (2, 1)' do
          grid[1, 1] = grid[3, 1] = :x
          grid[2, 2] = :o

          moves = AI.minimax(grid, :o)

          moves.size.must_equal 1
          [moves[0].row, moves[0].column].must_equal [2, 1]
        end
      end

      describe 'smart moves' do

        it 'should return (1, 3)' do
          grid[1, 1] = grid[3, 1] = :x
          grid[2, 1] = grid[3, 3] = :o

          moves = AI.minimax(grid, :x)

          moves.size.must_equal 1
          [moves[0].row, moves[0].column].must_equal [1, 3]
        end
      end
    end
  end
end
