require 'singleton'

require 'xo/grid'

module XO

  # This class defines an {Evaluator#analyze} method than can be used to look at a grid and
  # answer the following questions:
  #
  # 1. Is it a valid grid? A grid is considered valid if it possible for
  #    two players, taking turns, to reach the given grid configuration.
  # 2. Is there a winner/loser or is the grid squashed?
  # 3. Who is the winner/loser?
  # 4. Which positions make up the winning row, column and/or diagonal?
  #
  # The Evaluator class is a Singleton class and can be used as follows:
  #
  # @example
  #  Evaluator.instance.analyze(Grid.new('xo'), Grid::X)
  class Evaluator
    include Singleton

    # Analyze a given grid assuming that the given token is the one that was last placed on it.
    #
    # It can return a hash in following formats:
    #
    # - If everything is fine, then
    #
    #     { status: :ok }
    #
    # - If the game is over and the given token is in a winning position, then
    #
    #     { status: :game_over, type: :winner, details: [{ where: :a_where, index: :an_index, positions: :the_positions }] }
    #
    # - If the game is over and the other token is in a winning position, then
    #
    #     { status: :game_over, type: :loser, details: [{ where: :a_where, index: :an_index, positions: :the_positions }] }
    #
    # - If the game is over due to a squashed grid, then
    #
    #     { status: :game_over, type: :squashed }
    #
    # - If there is too much of one token, then
    #
    #     { status: :invalid_grid, type: :too_many_moves_ahead }
    #
    # - If both tokens are arranged in winning positions, then
    #
    #     { status: :invalid_grid, type: :two_winners }
    #
    # Legend:
    #
    # - :a_where is one of :row, :column, :diagonal
    # - :an_index is one of 1, 2, 3 if :a_where is :row or :column and one of 1, 2 if :a_where is :diagonal
    # - :the_positions is a 3 element array having the row, column values of the winning position
    #
    # Notice that the :details key is an array since it is possible to win a game in two different ways. For
    # example:
    #
    #    x | o | x
    #   ---+---+---
    #    o | x | o
    #   ---+---+---
    #    x | o | x
    #
    #   # Position (2, 2) would have to be the last position played for this to happen.
    #
    # @param grid [Grid] the grid to be analyzed
    # @param token [Grid::X, Grid::O] the token that was last placed on the grid
    # @raise [ArgumentError] unless token is either {Grid::X} or {Grid::O}
    # @return [Hash]
    def analyze(grid, token)
      raise ArgumentError, "illegal token #{token}" unless Grid.is_token?(token)

      @grid = grid
      @token = token
      @winners = {}

      perform_analysis
    end

    # Returns the number of {Grid::X}'s and {Grid::O}'s in the given grid.
    #
    # @example
    #  g = Grid.new('xoxxo')
    #  xs, os = Evaluator.instance.xos(g)
    #  puts xs # => 3
    #  puts os # => 2
    #
    # @return [Array(Integer, Integer)]
    def xos(grid)
      xs = os = 0

      grid.each do |_, _, val|
        xs += 1 if val == Grid::X
        os += 1 if val == Grid::O
      end

      [xs, os]
    end

    private

      attr_reader :grid, :token, :winners

      def perform_analysis
        return { status: :invalid_grid, type: :too_many_moves_ahead } if two_or_more_moves_ahead?

        find_winners

        if two_winners?
          { status: :invalid_grid, type: :two_winners }
        elsif winners[token]
          { status: :game_over, type: :winner, details: winners[token] }
        elsif winners[other_token]
          { status: :game_over, type: :loser, details: winners[other_token] }
        else
          if grid.full?
            { status: :game_over, type: :squashed }
          else
            { status: :ok }
          end
        end
      end

      def two_or_more_moves_ahead?
        moves_ahead >= 2
      end

      def moves_ahead
        xs, os = xos(grid)

        (xs - os).abs
      end

      def find_winners
        winning_positions.each do |w|
          a = grid[*w[:positions][0]]
          b = grid[*w[:positions][1]]
          c = grid[*w[:positions][2]]

          add_winner(a, w) if Grid.is_token?(a) && a == b && b == c
        end
      end

      def winning_positions
        @winning_positions ||= [
          { where: :row, index: 1, positions: [[1, 1], [1, 2], [1, 3]] },
          { where: :row, index: 2, positions: [[2, 1], [2, 2], [2, 3]] },
          { where: :row, index: 3, positions: [[3, 1], [3, 2], [3, 3]] },

          { where: :column, index: 1, positions: [[1, 1], [2, 1], [3, 1]] },
          { where: :column, index: 2, positions: [[1, 2], [2, 2], [3, 2]] },
          { where: :column, index: 3, positions: [[1, 3], [2, 3], [3, 3]] },

          { where: :diagonal, index: 1, positions: [[1, 1], [2, 2], [3, 3]] },
          { where: :diagonal, index: 2, positions: [[1, 3], [2, 2], [3, 1]] }
        ]
      end

      def add_winner(token, details)
        if winners.key?(token)
          winners[token] << details
        else
          winners[token] = [details]
        end
      end

      def two_winners?
        winners[Grid::X] && winners[Grid::O]
      end

      def other_token
        Grid.other_token(token)
      end
  end
end
