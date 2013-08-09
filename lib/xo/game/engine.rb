require 'xo/board'
require 'xo/game/idle_state'
require 'xo/game/playing_state'
require 'xo/game/game_over_state'

require 'ostruct'

module TTT::Game

  class Engine

    DEFAULT_LISTENER = Object.new
    def DEFAULT_LISTENER.handle_event(e); puts e; end

    attr_accessor :listener, :board, :turn, :state

    def initialize(args = {})
      @listener = args.fetch(:listener) { DEFAULT_LISTENER }
      @board = args.fetch(:board) { TTT::Board.new }
      @turn = :nobody

      @states = {
        idle: IdleState.new(self),
        playing: PlayingState.new(self),
        game_over: GameOverState.new(self)
      }

      change_to_idle_state
    end

    def start(token)
      raise ArgumentError, token unless TTT::Board.is_token?(token)
      state.start(token)
      self
    end

    def stop
      state.stop
      self
    end

    def play(r, c)
      state.play(r.to_i, c.to_i)
      self
    end

    def continue_playing(token)
      raise ArgumentError, token unless TTT::Board.is_token?(token)
      state.continue_playing(token)
      self
    end

    def send_event(name, message = {})
      event = message.merge(event: name)
      listener.handle_event(event)
    end

    def handle_start(token)
      self.turn = token
      board.clear
      change_to_playing_state
      send_event(:game_started, turn: token)
    end

    def handle_stop
      change_to_idle_state
      send_event(:game_stopped)
    end

    def handle_play(r, c)
      if TTT::Board.contains?(r, c)
        if board.free?(r, c)
          board[r, c] = turn

          result = board.state(turn)

          if result[:state] == :normal
            self.turn = next_turn
            send_event(:next_turn, who: self.turn, last_played_at: OpenStruct.new(row: r, col: c))
          elsif result[:state] == :game_over
            change_to_game_over_state

            if result[:reason] == :winner
              send_event(:game_over, reason: :winner, who: turn, last_played_at: OpenStruct.new(row: r, col: c), details: result[:details])
            elsif result[:reason] == :squashed
              send_event(:game_over, reason: :squashed, who: turn, last_played_at: OpenStruct.new(row: r, col: c))
            end
          end
        else
          send_event(:invalid_move, reason: :occupied)
        end
      else
        send_event(:invalid_move, reason: :out_of_bounds)
      end
    end

    def handle_continue_playing(token)
      self.turn = token
      board.clear
      change_to_playing_state
      send_event(:continue_playing, turn: token)
    end

    def next_turn
      TTT::Board.other_token(turn)
    end

    def idle_state; states[:idle]; end
    def playing_state; states[:playing]; end
    def game_over_state; states[:game_over]; end

    def change_to_idle_state; self.state = idle_state; end
    def change_to_playing_state; self.state = playing_state; end
    def change_to_game_over_state; self.state = game_over_state; end

    private

      attr_reader :states
  end
end
