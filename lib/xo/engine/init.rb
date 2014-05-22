require 'xo/engine/game_state'
require 'xo/engine/playing'

module XO

  class Init < GameState

    # Starts a new game.
    #
    # The engine is transitioned into the {Playing} state and the event
    #
    #   { name: :game_started }
    #
    # is triggered.
    #
    # @param turn [Grid::X, Grid::O] specifies which token has first play
    # @raise [ArgumentError] unless turn is either {Grid::X} or {Grid::O}
    def start(turn)
      game_context.check_turn(turn)
      game_context.set_turn_and_clear_grid(turn)
      engine.transition_to_state_and_send_event(Playing, :game_started)
    end
  end
end
