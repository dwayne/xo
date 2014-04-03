require 'xo/grid'
require 'xo/evaluator'
require 'xo/ai'

module XO::AI

  class Expert

    def self.suggest_moves(grid, player)
      result = XO::Evaluator.analyze(grid, player)

      case result[:status]
      when :ok
        get_moves(grid, player)
      when :game_over
        []
      else
        raise IllegalGridStatusError
      end
    end

    def self.get_moves(grid, player)
      if moves = MOVES_CACHE[grid] || MOVES_CACHE[invert_grid(grid)]
        moves.map { |pos| XO::Position.new(*pos) }
      else
        XO::AI.minimax(grid, player).moves
      end
    end

    def self.all_moves(grid)
      grid.enum_for(:each_free).map { |r, c| XO::Position.new(r, c) }
    end

    private

      def self.invert_grid(grid)
        (new_grid = grid.dup).each do |r, c, val|
          new_grid[r, c] = XO::other_token(val)
        end
      end

      def self.one_x_grid(r, c)
        XO::Grid.new.tap do |grid|
          grid[r, c] = :x
        end
      end

      MOVES_CACHE = {
        XO::Grid.new => [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]],

        one_x_grid(1, 1) => [[2, 2]],
        one_x_grid(1, 3) => [[2, 2]],
        one_x_grid(3, 1) => [[2, 2]],
        one_x_grid(3, 3) => [[2, 2]],

        one_x_grid(1, 2) => [[1, 1], [1, 3], [2, 2], [3, 2]],
        one_x_grid(2, 1) => [[1, 1], [2, 2], [2, 3], [3, 1]],
        one_x_grid(2, 3) => [[1, 3], [2, 1], [2, 2], [3, 3]],
        one_x_grid(3, 2) => [[1, 2], [2, 2], [3, 1], [3, 3]],

        one_x_grid(2, 2) => [[1, 1], [1, 3], [3, 1], [3, 3]]
      }
  end
end
