require_relative 'engine_state'

module TTT

  class IdleState < EngineState

    def start(token)
      engine.board.clear
      engine.turn = token
      engine.state = engine.playing_state
      engine.listener.handle_event({ event: :game_started, message: { turn: token } })
    end

    def stop; raise NotImplementedError, self.class; end
  end
end
