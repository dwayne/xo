require 'xo/ai/player'

module XO::AI

  class Hard < Player

    def moves(grid, turn)
      all_smart_moves(grid, turn)
    end
  end
end
