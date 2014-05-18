require 'singleton'

require 'xo/evaluator'
require 'xo/ai/geometric_grid'
require 'xo/ai/min_player'
require 'xo/ai/max_player'

module XO

  module AI

    # This class provides an implementation of the
    # {http://en.wikipedia.org/wiki/Minimax#Minimax_algorithm_with_alternate_moves minimax algorithm}. The minimax algorithm
    # is a recursive search algorithm used to find the next move in a 2-player (or n-player) game.
    #
    # The search space forms a tree where the root is the empty grid and every other node is a possible grid configuration that
    # can be reached by playing through a game of Tic-tac-toe.
    #
    # {Minimax} is a Singleton which can be used as follows:
    #
    # @example
    #  Minimax.instance.moves(XO::Grid.new('xox x o o'), XO::Grid::O) # => [[3, 2]]
    #
    # The first time the instance of Minimax is created, it runs the minimax algorithm to compute the value of all the nodes in the
    # search space. This of course takes a bit of time (~ 4 seconds), but subsequent calls are super fast.
    class Minimax
      include Singleton

      # Determines the best moves that can be made on the given grid, knowing that it's turn's time to play.
      #
      # @param grid [XO::Grid]
      # @param turn [XO::Grid::X, XO::Grid::O]
      # @raise [ArgumentError] if turn is not a token or the combination of the values of grid and turn doesn't make sense
      # @return [Array<Array(Integer, Integer)>]
      def moves(grid, turn)
        check_turn(turn)
        best_moves(*normalize(grid, turn))
      end

      private

        attr_reader :master_grid, :scores

        X = GeometricGrid::X
        O = GeometricGrid::O

        EMPTY = GeometricGrid::EMPTY

        MAX_PLAYER = MaxPlayer.new(X)
        MIN_PLAYER = MinPlayer.new(O)

        def initialize
          init_search
          build_search_tree
        end

        def init_search
          @master_grid = GeometricGrid.new
          @scores      = {}
        end

        def build_search_tree(player_a = MAX_PLAYER, player_b = MIN_PLAYER)
          return if has_score?

          analyze_grid(player_a)

          if terminal?
            set_terminal_score(player_a)
          else
            next_grids = []

            master_grid.each_open do |r, c|
              master_grid[r, c] = player_a.token
              next_grids << master_grid.dup

              build_search_tree(player_b, player_a)

              master_grid[r, c] = EMPTY
            end

            set_non_terminal_score(player_a, next_grids)
          end
        end

        def has_score?
          scores.key?(master_grid)
        end

        def analyze_grid(player)
          @result = Evaluator.new.analyze(master_grid, player.token)
        end

        def terminal?
          @result[:status] == :game_over
        end

        def set_terminal_score(player)
          scores[master_grid.dup] = player.terminal_score(@result[:type])
        end

        def set_non_terminal_score(player, next_grids)
          scores[master_grid.dup] = player.non_terminal_score(next_grids, scores)
        end

        # The search tree that gets built is for the situation when X is assumed to
        # have played first. However, if we are given a grid to evaluate such that
        # it can only be reached by assuming that O played first then we need to
        # patch things up so that we can find a representative in our search space
        # for the given configuration.
        def normalize(grid, turn)
          xs, os = Evaluator.xos(grid)

          if turn == X
            if xs == os
              [GeometricGrid.new(grid.inspect), X]
            elsif xs < os
              [invert(grid), O]
            else
              raise ArgumentError, "#{grid} and #{turn} is not a valid combination, too many X's"
            end
          else
            if xs == os
              [invert(grid), X]
            elsif xs > os
              [GeometricGrid.new(grid.inspect), O]
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

        def check_turn(turn)
          raise ArgumentError, "illegal token #{turn}" unless GeometricGrid.is_token?(turn)
        end

        def best_moves(grid, turn)
          final_score = @scores[grid]
          moves = []

          grid.each_open do |r, c|
            grid[r, c] = turn

            moves << [r, c] if @scores[grid] == final_score

            grid[r, c] = EMPTY
          end

          moves
        end
    end
  end
end
