require 'singleton'

require 'xo/evaluator'
require 'xo/ai/geometric_grid'

module XO

  module AI

    # This class provides an implementation of the
    # {http://en.wikipedia.org/wiki/Minimax#Minimax_algorithm_with_alternate_moves minimax algorithm}. The minimax algorithm
    # is a recursive search algorithm used to find the next move in a 2-player (or n-player) game.
    #
    # The search space forms a tree where the root is the empty grid and every other node is a possible grid configuration that
    # can be reached by playing through a game of Tic-tac-toe.
    #
    # Given any node in the tree and an indication of whose turn it is to play next, all the node's children can be determined by
    # making one move in each of its open positions. For example, given the node
    #
    #    x | o | x
    #   ---+---+---
    #      | x |
    #   ---+---+---
    #    o |   | o
    #
    # and knowing that it's {XO::Grid::O}'s (the min player) turn to play. Then, its children will be the 3 nodes
    #
    #        A             B             C
    #
    #    x | o | x     x | o | x     x | o | x
    #   ---+---+---   ---+---+---   ---+---+---
    #    o | x |         | x | o       | x |
    #   ---+---+---   ---+---+---   ---+---+---
    #    o |   | o     o |   | o     o | o | o
    #
    # since there are 3 open positions in which {XO::Grid::O} can make a move.
    #
    # Within the implementation, A and B will be considered intermediate nodes and so the search algorithm will have to continue until
    # it can make a conclusive determination. That occurs when it reaches a terminal node, like C. In that case, the algorithm assigns
    # a value to the terminal node from the perspective of the player that has to play next. So in C's case,
    # {XO::Grid::X} (the max player) has to play next. But {XO::Grid::X} can't play because {XO::Grid::O} won. So {XO::Grid::X} would
    # value C with a low value, -1 in this case.
    #
    # Each intermediate node can now get a value in the following way. Consider node A. It's {XO::Grid::X}'s turn to play and
    # {XO::Grid::X} is the max player. The max player seeks to maximize their value over all the values of its children (conversely,
    # the min player seeks to minimize their value over all its children). It has 2 children and they will eventually be determined
    # to have the values 0 and -1. Since 0 is greater than -1, A will get the value of 0. What this means essentially is that the max
    # player will play to favor a squashed game rather than a losing game in this particular instance.
    #
    # It is interesting to note that B is simply a reflection of A and so will end up having the same value. The algorithm below is
    # smart enough to recognize that and so it will not have to perform a similar calculation in B's case.
    #
    # The Minimax class is a Singleton class. You use it as follows:
    #
    # @example
    #  Minimax.instance.moves(XO::Grid.new('xox x o o'), XO::Grid::O) # => [[3, 2]]
    #
    # The first time the instance of Minimax is created, it runs the minimax algorithm to compute the value of all the nodes in the
    # search space. This of course takes a bit of time (~ 4 seconds), but subsequent calls are instantaneous.
    class Minimax
      include Singleton

      # Determines the best moves that can be made on the given grid, knowing that it's turn's time to play.
      #
      # @param grid [XO::Grid]
      # @param turn [XO::Grid::X, XO::Grid::O]
      # @raise [ArgumentError] if turn is not a token or the combination of the values of grid and turn doesn't make sense
      # @return [Array<Array(Integer, Integer)>]
      def moves(grid, turn)
        raise ArgumentError, "illegal token #{turn}" unless GeometricGrid.is_token?(turn)

        best_moves(*lift(grid, turn))
      end

      private

        attr_reader :the_grid, :scores

        def initialize
          init_search
          build_search_tree
        end

        def init_search
          @the_grid = GeometricGrid.new
          @scores = {}
        end

        def build_search_tree(player = MaxPlayer)
          return if has_score?

          analyze_grid(player)

          if terminal?
            set_score(player)
          else
            next_grids = []

            the_grid.each_open do |r, c|
              the_grid[r, c] = player.token
              next_grids << the_grid.dup

              build_search_tree(player.other)

              the_grid[r, c] = :e
            end

            set_final_score(player, next_grids)
          end
        end

        def has_score?
          scores.key?(the_grid)
        end

        def analyze_grid(player)
          @results = Evaluator.new.analyze(the_grid, player.token)
        end

        def terminal?
          @results[:status] == :game_over
        end

        def set_score(player)
          scores[the_grid.dup] = player.score(@results[:type])
        end

        def set_final_score(player, next_grids)
          scores[the_grid.dup] = player.final_score(next_grids, scores)
        end

        # The search tree that gets built is for the situation when {XO::Grid::X} is assumed to
        # have played first. However, if we are given a grid to evaluate such that
        # it can only be reached by assuming that {XO::Grid::O} played first then we need to
        # patch things up so that we can find a representative in our search space
        # for the given configuration.
        def lift(grid, turn)
          xs, os = Evaluator.xos(grid)

          if turn == GeometricGrid::X
            if xs == os
              [GeometricGrid.new(grid.inspect), GeometricGrid::X]
            elsif xs < os
              [invert(grid), GeometricGrid::O]
            else
              raise ArgumentError, "#{grid} and #{turn} is not a valid combination, too many X's"
            end
          else
            if xs == os
              [invert(grid), GeometricGrid::X]
            elsif xs > os
              [GeometricGrid.new(grid.inspect), GeometricGrid::O]
            else
              raise ArgumentError, "#{grid} and #{turn} is not a valid combination, too many O's"
            end
          end
        end

        def invert(grid)
          inverted_grid = GeometricGrid.new

          grid.each do |r, c, val|
            inverted_grid[r, c] = GeometricGrid.other_token(val)
          end

          inverted_grid
        end

        def best_moves(grid, turn)
          final_score = @scores[grid]
          moves = []

          grid.each_open do |r, c|
            grid[r, c] = turn

            moves << [r, c] if @scores[grid] == final_score

            grid[r, c] = :e
          end

          moves
        end
    end

    module MaxPlayer

      def self.token
        GeometricGrid::X
      end

      def self.other
        MinPlayer
      end

      def self.score(type)
        { winner: 1, loser: -1, squashed: 0 }[type]
      end

      def self.final_score(next_grids, scores)
        next_grids.map { |grid| scores[grid] }.max
      end
    end

    module MinPlayer

      def self.token
        GeometricGrid::O
      end

      def self.other
        MaxPlayer
      end

      def self.score(type)
        { winner: -1, loser: 1, squashed: 0 }[type]
      end

      def self.final_score(next_grids, scores)
        next_grids.map { |grid| scores[grid] }.min
      end
    end
  end
end
