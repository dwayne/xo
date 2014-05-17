require 'xo/grid'

module XO

  # {Evaluator} defines an {#analyze} method than can be used to examine a grid to answer the following questions:
  #
  # 1. Is it a valid grid? A grid is considered valid if it possible for two players, taking turns, to reach the given grid configuration.
  # 2. Is there a winner/loser or is the grid squashed?
  # 3. Who is the winner/loser?
  # 4. Which positions make up the winning row, column and/or diagonal?
  class Evaluator

    # Examines the given grid assuming that the given token is the one that was last placed on it.
    #
    # The following return values are possible:
    #
    # - If everything is fine, then
    #
    #     { status: :ok }
    #
    # - If the game is over and the given token is in a winning position, then
    #
    #     { status: :game_over, type: :winner, details: [{ where: :where, index: :index, positions: :positions }] }
    #
    # - If the game is over and the other token is in a winning position, then
    #
    #     { status: :game_over, type: :loser, details: [{ where: :where, index: :index, positions: :positions }] }
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
    # - :where is one of :row, :column, :diagonal
    # - :index is one of 1, 2, 3 if :where is :row or :column and one of 1, 2 if :where is :diagonal
    # - :positions is a 3 element array having the row, column values of the winning position
    #
    # Notice that the :details key is an array since it is possible to win a game in two different ways. For example:
    #
    #    x | o | x
    #   ---+---+---
    #    o | x | o
    #   ---+---+---
    #    x | o | x
    #
    # @param grid [Grid] the grid to be examined
    # @param token [Grid::X, Grid::O] the token that was last placed on the grid
    # @raise [ArgumentError] unless token is either {Grid::X} or {Grid::O}
    # @return [Hash]
    def analyze(grid, token)
      check_token(token)
      initialize_analyzer(grid, token)
      perform_analysis
    end

    # Returns the number of {Grid::X}'s and {Grid::O}'s in the given grid.
    #
    # @example
    #  g = Grid.new('xoxxo')
    #  xs, os = Evaluator.xos(g)
    #  puts xs # => 3
    #  puts os # => 2
    #
    # @return [Array(Integer, Integer)]
    def self.xos(grid)
      xs = os = 0

      grid.each do |_, _, k|
        xs += 1 if k == Grid::X
        os += 1 if k == Grid::O
      end

      [xs, os]
    end

    private

      attr_reader :grid, :token, :winners

      def check_token(token)
        raise ArgumentError, "illegal token #{token}" unless Grid.is_token?(token)
      end

      def initialize_analyzer(grid, token)
        @grid    = grid
        @token   = token
        @winners = {}
      end

      def perform_analysis
        return { status: :invalid_grid, type: :too_many_moves_ahead }              if two_or_more_moves_ahead?

        find_winners

        return { status: :invalid_grid, type: :two_winners }                       if two_winners?
        return { status: :game_over, type: :winner, details: winners[token] }      if winners[token]
        return { status: :game_over, type: :loser, details: winners[other_token] } if winners[other_token]
        return { status: :game_over, type: :squashed }                             if grid.full?
        return { status: :ok }
      end

      def two_or_more_moves_ahead?
        moves_ahead >= 2
      end

      def moves_ahead
        xs, os = self.class.xos(grid)

        (xs - os).abs
      end

      WINNING_POSITIONS = [
        { where: :row,      index: 1, positions: [[1, 1], [1, 2], [1, 3]] },
        { where: :row,      index: 2, positions: [[2, 1], [2, 2], [2, 3]] },
        { where: :row,      index: 3, positions: [[3, 1], [3, 2], [3, 3]] },

        { where: :column,   index: 1, positions: [[1, 1], [2, 1], [3, 1]] },
        { where: :column,   index: 2, positions: [[1, 2], [2, 2], [3, 2]] },
        { where: :column,   index: 3, positions: [[1, 3], [2, 3], [3, 3]] },

        { where: :diagonal, index: 1, positions: [[1, 1], [2, 2], [3, 3]] },
        { where: :diagonal, index: 2, positions: [[1, 3], [2, 2], [3, 1]] }
      ]

      def find_winners
        WINNING_POSITIONS.each do |w|
          x = grid[*w[:positions][0]]
          y = grid[*w[:positions][1]]
          z = grid[*w[:positions][2]]

          add_winner(x, w.dup) if winning_combination(x, y, z)
        end
      end

      def add_winner(token, details)
        if winners.key?(token)
          winners[token] << details
        else
          winners[token] = [details]
        end
      end

      def winning_combination(x, y, z)
        Grid.is_token?(x) && x == y && y == z
      end

      def two_winners?
        winners.keys.length == 2
      end

      def other_token
        Grid.other_token(token)
      end
  end
end
