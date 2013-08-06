require_relative 'board'
require_relative 'referee'
require_relative 'idle_state'
require_relative 'playing_state'
require_relative 'game_over_state'

require 'ostruct'

module TTT

  class Engine

    DEFAULT_LISTENER = OpenStruct.new
    def DEFAULT_LISTENER.handle_event(e); puts e; end

    attr_accessor :state, :listener, :turn, :board, :referee

    def initialize(listener = DEFAULT_LISTENER)
      @listener = listener

      @states = {
        idle: IdleState.new(self),
        playing: PlayingState.new(self),
        game_over: GameOverState.new(self)
      }

      @turn = :nobody

      # FIXME: Keep your options open, use dependency injection for both board and referee
      @board = Board.new
      @referee = Referee.new(@board)

      @state = idle_state
    end

    def next_turn
      turn == :x ? :o : (turn == :o ? :x : turn)
    end

    def next_turn!
      self.turn = next_turn
    end

    def start(token)
      raise ArgumentError, token unless is_token?(token)
      state.start(token)
      self
    end

    def stop
      state.stop
      self
    end

    def play(r, c)
      state.play(r, c)
      self
    end

    def continue_playing(token)
      raise ArgumentError, token unless is_token?(token)
      state.continue_playing(token)
      self
    end

    def idle_state; states[:idle]; end
    def playing_state; states[:playing]; end
    def game_over_state; states[:game_over]; end

    private

      attr_reader :states

      def is_token?(val)
        [:x, :o].include?(val)
      end
  end
end
