require 'xo/game/state'

module TTT::Game

  class PlayingState < State

    def play(r, c)
      engine.handle_play(r, c)
    end
  end
end
