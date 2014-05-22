require 'xo/engine/game_state'

module XO

  class GameOver < GameState

    # Stops and resets a game.
    #
    # The engine is transitioned into the {Init} state and the event
    #
    #   { name: :game_stopped }
    #
    # is triggered.
    def stop
      stop_game
    end

    # Starts another new game.
    #
    # The token that won plays first, otherwise the game was squashed and so
    # the next token plays first.
    #
    # The engine is transitioned into the {Playing} state and the event
    #
    #   { name: :game_started, type: :continue_playing }
    #
    # is triggered.
    def continue_playing
      game_context.set_turn_and_clear_grid(game_context.turn)
      engine.transition_to_state_and_send_event(Playing, :game_started, type: :continue_playing)
    end
  end
end
