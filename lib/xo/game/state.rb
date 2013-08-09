module TTT
  module Game

    class State

      attr_accessor :engine

      def initialize(engine)
        @engine = engine
      end

      def stop
        engine.handle_stop
      end

      def start(token); raise NotImplementedError, self.class; end
      def play(r, c); raise NotImplementedError, self.class; end
      def continue_playing(token); raise NotImplementedError, self.class; end
    end
  end
end
