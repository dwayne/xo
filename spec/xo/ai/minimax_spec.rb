require 'spec_helper'

module XO::AI

  describe Minimax do

    let(:minimax) { Minimax.new }

    describe "immediate wins" do

      it "should return (1, 3)" do
        grid = XO::Grid.new('xx oo')

        moves = minimax.moves(grid, XO::Grid::X)

        moves.must_equal [[1, 3]]
      end

      it "should return (1, 3), (3, 2) and (3, 3)" do
        grid = XO::Grid.new('oo xoxx')

        moves = minimax.moves(grid, XO::Grid::O)

        moves.must_equal [[1, 3], [3, 2], [3, 3]]
      end
    end

    describe "blocking moves" do

      it "should return (2, 1)" do
        grid = XO::Grid.new('x   o x')

        moves = minimax.moves(grid, XO::Grid::O)

        moves.must_equal [[2, 1]]
      end
    end

    describe "smart moves" do

      it "should return (1, 3)" do
        grid = XO::Grid.new('x  o  x o')

        moves = minimax.moves(grid, XO::Grid::X)

        moves.must_equal [[1, 3]]
      end

      it "should return (1, 2), (2, 1), (2, 3), (3, 2)" do
        grid = XO::Grid.new('  o x o')

        moves = minimax.moves(grid, XO::Grid::X)

        moves.must_equal [[1, 2], [2, 1], [2, 3], [3, 2]]
      end

      it "should return (1, 3), (3, 1)" do
        grid = XO::Grid.new('x   x   o')

        moves = minimax.moves(grid, XO::Grid::O)

        moves.must_equal [[1, 3], [3, 1]]
      end
    end
  end
end
