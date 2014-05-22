require 'xo/grid'

module XO

  class GameContext < Struct.new(:turn, :grid)

    def reset
      set_turn_and_clear_grid(:nobody)
    end

    def set_turn_and_clear_grid(turn)
      self.turn = turn
      grid.clear
    end

    def switch_turns
      self.turn = next_turn
    end

    def next_turn
      Grid.other_token(turn)
    end

    def check_turn(turn)
      raise ArgumentError, "invalid turn symbol, #{turn}" unless Grid.is_token?(turn)
    end
  end
end
