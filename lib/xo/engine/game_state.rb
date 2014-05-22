require 'state_design_pattern'

module XO

  class GameState < StateDesignPattern::BaseState
    def_actions :start, :stop, :play, :continue_playing

    private

      alias_method :engine, :state_machine

      def game_context
        engine.context
      end

      def stop_game
        game_context.reset
        engine.transition_to_state_and_send_event(Init, :game_stopped)
      end
  end
end
