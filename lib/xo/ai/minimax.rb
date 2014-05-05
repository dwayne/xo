require 'singleton'

require 'xo/evaluator'
require 'xo/ai/geometric_grid'

module XO

  module AI

    class Minimax
      include Singleton

      def moves(grid, turn)
        raise ArgumentError, "illegal token #{turn}" unless XO::Grid.is_token?(turn)

        best_moves(*lift(grid, turn))
      end

      private

        attr_reader :the_grid, :scores

        def initialize
          @the_grid = GeometricGrid.new
          @scores = {}

          build_tree
        end

        def build_tree(player = MaxPlayer)
          return if has_score?

          analyze_grid(player)

          if terminal?
            set_score(player)
          else
            next_grids = []

            the_grid.each_open do |r, c|
              the_grid[r, c] = player.token
              next_grids << the_grid.dup

              build_tree(player.other)

              the_grid[r, c] = :e
            end

            set_final_score(player, next_grids)
          end
        end

        def has_score?
          scores.key?(the_grid)
        end

        def analyze_grid(player)
          @results = Evaluator.analyze(the_grid, player.token)
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

        module MaxPlayer

          def self.token
            XO::Grid::X
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
            XO::Grid::O
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

        # Determines the geometric grid and turn to be used so that we
        # can find a solution in the situation when {Grid::X} played first.
        def lift(grid, turn)
          xs, os = Evaluator.xos(grid)

          if turn == XO::Grid::X
            if xs == os
              [GeometricGrid.new(grid.inspect), XO::Grid::X]
            else # xs < os, can't be xs > os since that's an invalid situation
              [invert(grid), XO::Grid::O]
            end
          else
            if xs == os
              [invert(grid), XO::Grid::X]
            else # xs > os, can't be xs < os since that's an invalid situation
              [GeometricGrid.new(grid.inspect), XO::Grid::O]
            end
          end
        end

        def invert(grid)
          inverted_grid = GeometricGrid.new

          grid.each do |r, c, val|
            inverted_grid[r, c] = XO::Grid.other_token(val)
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
  end
end
