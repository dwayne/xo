require_relative 'engine_state'

module TTT

  class GameOverState < EngineState

    def continue_playing(token)
      engine.board.clear
      engine.turn = token
      engine.state = engine.playing_state
      engine.listener.handle_event({ event: :continue_playing, message: { turn: token } })
    end
  end
end
