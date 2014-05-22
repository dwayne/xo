require 'state_design_pattern'

module XO

  class GameState < StateDesignPattern::BaseState
    def_actions :start, :stop, :play, :continue_playing

    private

      alias_method :engine, :state_machine

      def game_context
        engine.context
      end

      def start_game(turn, message = {})
        game_context.check_turn(turn)
        game_context.set_turn_and_clear_grid(turn)
        engine.transition_to_state_and_send_event(Playing, :game_started, message)
      end

      def stop_game
        game_context.reset
        engine.transition_to_state_and_send_event(Init, :game_stopped)
      end
  end
end
