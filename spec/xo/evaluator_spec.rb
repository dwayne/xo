require 'spec_helper'

module XO

  describe Evaluator do

    let (:evaluator) { Evaluator.instance }
    let (:grid) { Grid.new }

    describe "#analyze" do

      describe "standard play" do

        it "returns ok" do
          result = { status: :ok }

          evaluator.analyze(grid, Grid::X).must_equal result
          evaluator.analyze(grid, Grid::O).must_equal result

          grid[1, 1] = Grid::X

          evaluator.analyze(grid, Grid::X).must_equal result
          evaluator.analyze(grid, Grid::O).must_equal result
        end
      end

      describe "game over" do

        describe "winners and losers" do

          it "returns a row 1 winner/loser" do
            grid[1, 1] = grid[1, 2] = grid[1, 3] = Grid::X
            grid[2, 1] = grid[2, 2] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :row,
                index: 1,
                positions: [[1, 1], [1, 2], [1, 3]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a row 2 winner/loser" do
            grid[2, 1] = grid[2, 2] = grid[2, 3] = Grid::X
            grid[1, 1] = grid[1, 2] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :row,
                index: 2,
                positions: [[2, 1], [2, 2], [2, 3]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a row 3 winner/loser" do
            grid[3, 1] = grid[3, 2] = grid[3, 3] = Grid::X
            grid[1, 1] = grid[1, 2] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :row,
                index: 3,
                positions: [[3, 1], [3, 2], [3, 3]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a column 1 winner/loser" do
            grid[1, 1] = grid[2, 1] = grid[3, 1] = Grid::X
            grid[1, 2] = grid[2, 2] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :column,
                index: 1,
                positions: [[1, 1], [2, 1], [3, 1]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a column 2 winner/loser" do
            grid[1, 2] = grid[2, 2] = grid[3, 2] = Grid::X
            grid[1, 1] = grid[2, 1] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :column,
                index: 2,
                positions: [[1, 2], [2, 2], [3, 2]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a column 3 winner/loser" do
            grid[1, 3] = grid[2, 3] = grid[3, 3] = Grid::X
            grid[1, 1] = grid[2, 1] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :column,
                index: 3,
                positions: [[1, 3], [2, 3], [3, 3]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a diagonal 1 winner/loser" do
            grid[1, 1] = grid[2, 2] = grid[3, 3] = Grid::X
            grid[1, 2] = grid[2, 1] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :diagonal,
                index: 1,
                positions: [[1, 1], [2, 2], [3, 3]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end

          it "returns a diagonal 2 winner/loser" do
            grid[1, 3] = grid[2, 2] = grid[3, 1] = Grid::X
            grid[1, 2] = grid[2, 3] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :diagonal,
                index: 2,
                positions: [[1, 3], [2, 2], [3, 1]]
              }]
            }

            evaluator.analyze(grid, Grid::X).must_equal result

            result[:type] = :loser
            evaluator.analyze(grid, Grid::O).must_equal result
          end
        end

        describe "a highly unlikely but definitely possible two-way winner/loser" do
          # I mean you have to be real messed up to lose a game in this manner. :P

          # The X win
          it "returns a diagonal 1 and 2 winner/loser" do
            grid[1, 1] = grid[1, 3] = grid[2, 2] = grid[3, 1] = grid[3, 3] = Grid::X
            grid[1, 2] = grid[2, 1] = grid[2, 3] = grid[3, 2] = Grid::O

            result = {
              status: :game_over,
              type: :winner,
              details: [{
                where: :diagonal,
                index: 1,
                positions: [[1, 1], [2, 2], [3, 3]]
              }, {
                where: :diagonal,
                index: 2,
                positions: [[1, 3], [2, 2], [3, 1]]
              }]
            }
          end
        end

        describe "a squashed grid" do

          it "returns squashed" do
            grid[1, 1] = grid[1, 2] = grid[2, 3] = grid[3, 1] = grid[3, 3] = Grid::X
            grid[1, 3] = grid[2, 1] = grid[2, 2] = grid[3, 2] = Grid::O

            result = { status: :game_over, type: :squashed }

            evaluator.analyze(grid, Grid::X).must_equal result
            evaluator.analyze(grid, Grid::O).must_equal result
          end
        end
      end

      describe "invalid grid input" do

        it "returns too many moves ahead" do
          grid[1, 1] = grid[1, 2] = grid[1, 3] = Grid::X
          grid[2, 1] = Grid::O

          result = { status: :invalid_grid, type: :too_many_moves_ahead }

          evaluator.analyze(grid, Grid::X).must_equal result
          evaluator.analyze(grid, Grid::O).must_equal result
        end

        it "returns two winners" do
          grid[1, 1] = grid[1, 2] = grid[1, 3] = Grid::X
          grid[2, 1] = grid[2, 2] = grid[2, 3] = Grid::O

          result = { status: :invalid_grid, type: :two_winners }

          evaluator.analyze(grid, Grid::X).must_equal result
          evaluator.analyze(grid, Grid::O).must_equal result
        end
      end

      describe "invalid token input" do

        it "raises ArgumentError" do
          proc { evaluator.analyze(Grid.new, :not_a_token) }.must_raise ArgumentError
        end
      end
    end
  end
end
