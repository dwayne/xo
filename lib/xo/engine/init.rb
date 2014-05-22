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
      start_game(turn)
    end
  end
end
