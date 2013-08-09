require 'xo/game/state'

module TTT::Game

  class IdleState < State

    def start(token)
      engine.handle_start(token)
    end

    def stop; raise NotImplementedError, self.class; end
  end
end
