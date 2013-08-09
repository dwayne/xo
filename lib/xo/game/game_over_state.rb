require 'xo/game/state'

module TTT::Game

  class GameOverState < State

    def continue_playing(token)
      engine.handle_continue_playing(token)
    end
  end
end
