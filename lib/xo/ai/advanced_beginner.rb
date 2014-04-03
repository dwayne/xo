require 'xo/ai/expert'

module XO::AI

  class AdvancedBeginner < Expert

    def self.get_moves(grid, player)
      smart_moves = super(grid, player)
      dumb_moves  = all_moves - smart_moves

      # if there are no dumb moves then we have no choice but to make a smart move
      # otherwise, 75% of the time we'll make a smart move and the other 25% of the
      # time we'll make a dumb move
      dumb_moves.empty? ? smart_moves : (rand < 0.75 ? smart_moves : dumb_moves)
    end
  end
end
