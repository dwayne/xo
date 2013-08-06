module TTT

  class EngineState

    attr_reader :engine

    def initialize(engine)
      @engine = engine
    end

    def stop
      engine.state = engine.idle_state
      engine.listener.handle_event({ event: :game_stopped })
    end

    def start(token); raise NotImplementedError, self.class; end
    def play(r, c); raise NotImplementedError, self.class; end
    def continue_playing(token); raise NotImplementedError, self.class; end
  end
end
