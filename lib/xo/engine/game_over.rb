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
    # The engine is transitioned into the {Playing} state and the event
    #
    #   { name: :game_started, type: :continue_playing }
    #
    # is triggered.
    #
    # @param turn [Grid::X, Grid::O] specifies which token has first play
    # @raise [ArgumentError] unless turn is either {Grid::X} or {Grid::O}
    def continue_playing(turn)
      start_game(turn, type: :continue_playing)
    end
  end
end
