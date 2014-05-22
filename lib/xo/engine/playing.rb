require 'xo/engine/game_state'
require 'xo/engine/game_over'

module XO

  class Playing < GameState

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

    # Attempts to make a move at the given position (r, c).
    #
    # The following outcomes are possible:
    #
    # - If the position is *out* *of* *bounds*, then the event below is
    #   triggered and the engine remains in this state.
    #
    #     { name: :invalid_move, type: :out_of_bounds }
    #
    # - If the position is *occupied*, then the event below is triggered and the
    #   engine remains in this state.
    #
    #     { name: :invalid_move, type: :occupied }
    #
    # - If the move results in a *win*, then the event below is triggered and
    #   the engine is transitioned into the {GameOver} state.
    #
    #     { name: :game_over, type: :winner, last_move: { turn: :token, r: :row, c: :column }, details: :details }
    #
    # - If the move results in a *squashed* game, then the event below is
    #   triggered and the engine is transitioned into the {GameOver} state.
    #
    #     { name: :game_over, type: :squashed, last_move: { turn: :next_token, r: :row, c: :column } }
    #
    # - Otherwise, the event below is triggered and the engine remains in this
    #   state.
    #
    #     { name: :next_turn, last_move: { turn: :token, r: :row, c: :column } }
    #
    # *Legend:*
    #
    # - *:token* is one of {Grid::X} or {Grid::O}
    # - *:next_token* is one of {Grid::X} or {Grid::O}
    # - *:row* is one of 1, 2 or 3
    # - *:column* is one of 1, 2 or 3
    # - *:details* is taken verbatim from the :details key of the returned hash of {Evaluator#analyze}
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    def play(r, c)
      return engine.send_event(:invalid_move, type: :out_of_bounds) unless Grid.contains?(r, c)
      return engine.send_event(:invalid_move, type: :occupied) unless game_context.grid.open?(r, c)

      game_context.grid[r, c] = game_context.turn
      last_move = { turn: game_context.turn, r: r, c: c }

      result = engine.evaluator.analyze(game_context.grid, game_context.turn)

      case result[:status]
      when :ok
        game_context.switch_turns
        engine.send_event(:next_turn, last_move: last_move)
      when :game_over
        case result[:type]
        when :winner
          engine.transition_to_state_and_send_event(
            GameOver,
            :game_over, type: :winner, last_move: last_move, details: result[:details]
          )
        when :squashed
          game_context.switch_turns
          engine.transition_to_state_and_send_event(
            GameOver,
            :game_over, type: :squashed, last_move: last_move
          )
        end
      end
    end
  end
end
