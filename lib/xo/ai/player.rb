require 'xo/ai/minimax'

module XO::AI

  class Player

    def moves(grid, turn)
      raise NotImplementedError
    end

    protected

      def all_open_moves(grid)
        moves = []

        grid.each_open do |r, c|
          moves << [r, c]
        end

        moves
      end

      def all_smart_moves(grid, turn)
        Minimax.instance.moves(grid, turn)
      end
  end
end
