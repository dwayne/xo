require_relative 'board'
require_relative 'engine_state'
require 'ostruct'

module TTT

  class PlayingState < EngineState

    # Events sent by #play
    #
    # { event: :out_of_bounds }
    # { event: :occupied }
    # { event: :next_turn, message: { who: :token, last_play: OpenStruct.new(r: :integer, c: :integer) } }
    # { event: :game_over, message: { type: :winner, who: :token, last_play: OpenStruct.new(r: :integer, c: :integer), details: :array_of_details } }
    # { event: :game_over, message: { type: :squashed, who: :token, last_play: OpenStruct.new(r: :integer, c: :integer) } }
    #
    # For :array_of_details, see the Referee class.

    def play(r, c)
      if Board.contains?(r, c)
        if engine.board.free?(r, c)
          engine.board[r, c] = engine.turn

          status = engine.referee.check_status(engine.turn)

          if status[:event] == :game_still_in_progress
            engine.next_turn!

            engine.listener.handle_event({
              event: :next_turn,
              message: {
                who: engine.turn,
                last_play: OpenStruct.new(r: r, c: c)
              }
            })
          elsif status[:event] == :game_over
            engine.state = engine.game_over_state

            if status[:message][:type] == :winner
              engine.listener.handle_event({
                event: :game_over,
                message: {
                  type: :winner,
                  who: engine.turn,
                  last_play: OpenStruct.new(r: r, c: c),
                  details: status[:message][:details]
                }
              })
            elsif status[:message][:type] == :squashed
              engine.listener.handle_event({
                event: :game_over,
                message: {
                  type: :squashed,
                  who: engine.turn,
                  last_play: OpenStruct.new(r: r, c: c)
                }
              })
            end
          end
        else
          engine.listener.handle_event({ event: :occupied })
        end
      else
        engine.listener.handle_event({ event: :out_of_bounds })
      end
    end
  end
end
