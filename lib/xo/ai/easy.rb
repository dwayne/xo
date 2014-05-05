require 'xo/ai/player'

module XO::AI

  class Easy < Player

    def moves(grid, turn)
      all_open_moves(grid)
    end
  end
end
