require 'xo/grid'
require 'xo/evaluator'

module XO

  # A state machine that encapsulates the game logic for Tic-tac-toe. The operation
  # of the engine is completely determined by the properties:
  #
  # - {#state},
  # - {#turn},
  # - {#grid}, and
  # - {#last_event}.
  #
  # The engine can be in one of the 3 following states (represented by a symbol):
  #
  # - :init
  # - :playing
  # - :game_over
  #
  # The engine begins in the :init state. And, the following methods are used to advance
  # a single game of Tic-tac-toe (and transition the engine between its states) by obeying
  # the standard rules of Tic-tac-toe:
  #
  # - {#start}: [:init]
  # - {#stop}: [:playing, :game_over]
  # - {#play}: [:playing]
  # - {#continue_playing}: [:game_over]
  #
  # The array of symbols after each method lists the states in which the method is allowed
  # to be called.
  #
  # @example
  #  e = Engine.new
  #  e.start(Grid::X).play(1, 1).play(2, 1).play(1, 2).play(2, 2).play(1, 3)
  #
  #  event = e.last_event
  #  puts event[:name]             # => :game_over
  #  puts event[:type]             # => :winner
  #  puts event[:last_move][:turn] # => Grid::X
  #
  #  e.continue_playing(Grid::O).play(2, 2).play(1, 1).play(3, 3).play(1, 3).play(1, 2).play(3, 2).play(2, 1).play(2, 3).play(3, 1)
  #
  #  event = e.last_event
  #  puts event[:name]             # => :game_over
  #  puts event[:type]             # => :squashed
  #  puts event[:last_move][:turn] # => Grid::O
  class Engine

    # @return [:init, :playing, :game_over]
    attr_reader :state

    # @return [Grid::X, Grid::O, :nobody]
    attr_reader :turn

    # @return [Hash]
    attr_reader :last_event

    # Creates a new {Engine} with its state set to :init, turn set to :nobody, an empty grid and
    # last_event set to { name: :new }.
    def initialize
      @grid = Grid.new

      reset

      set_event(:new)
    end

    # Get the grid that's managed by the engine.
    #
    # @return [Grid] a copy of the grid that the engine uses
    def grid
      @grid.dup
    end

    # If the current turn is either {Grid::X}, {Grid::O} or :nobody then
    # it returns {Grid::O}, {Grid::X}, :nobody respectively.
    #
    # @return [Grid::X, Grid::O, :nobody]
    def next_turn
      Grid.other_token(turn)
    end

    # Transitions the engine from the :init state into the :playing state.
    #
    # Sets the last event to be:
    #
    #   { name: :game_started }
    #
    # @param turn [Grid::X, Grid::O] the token to have first play
    # @raise [ArgumentError] unless turn is either {Grid::X} or {Grid::O}
    # @raise [IllegalStateError] unless it's called in the :init state
    # @return [self]
    def start(turn)
      check_turn(turn)

      case state
      when :init
        handle_start(turn)
      else
        raise IllegalStateError, "must be in the :init state but state = :#{state}"
      end
    end

    # Transitions the engine from the :playing or :game_over state into the :game_over state.
    #
    # Sets the last event to be:
    #
    #   { name: :game_over }
    #
    # @raise [IllegalStateError] unless it's called in the :playing or :game_over state
    # @return [self]
    def stop
      case state
      when :playing, :game_over
        handle_stop
      else
        raise IllegalStateError, "must be in the :playing or :game_over state but state = :#{state}"
      end
    end

    # Makes a move at the given position (r, c) which may transition the engine into the :game_over state
    # or leave it in the :playing state.
    #
    # Sets the last event as follows:
    #
    # - If the position is out of bounds, then
    #
    #     { name: :invalid_move, type: :out_of_bounds }
    #
    # - If the position is occupied, then
    #
    #     { name: :invalid_move, type: :occupied }
    #
    # - If the move was allowed and didn't result in ending the game, then
    #
    #     { name: :next_turn, last_move: { turn: :a_token, r: :a_row, c: :a_column } }
    #
    # - If the move was allowed and resulted in a win, then
    #
    #     { name: :game_over, type: :winner, last_move: { turn: :a_token, r: :a_row, c: :a_column }, details: :the_details }
    #
    # - If the move was allowed and resulted in a squashed game, then
    #
    #     { name: :game_over, type: :squashed, last_move: { turn: :a_token, r: :a_row, c: :a_column } }
    #
    # Legend:
    #
    # - :a_token is one of {Grid::X} or {Grid::O}
    # - :a_row is one of 1, 2 or 3
    # - :a_column is one of 1, 2 or 3
    # - :the_details is taken verbatim from the :details key of the returned hash of {Evaluator.analyze}
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    # @raise [IllegalStateError] unless it's called in the :playing state
    # @return [self]
    def play(r, c)
      case state
      when :playing
        handle_play(r, c)
      else
        raise IllegalStateError, "must be in the :playing state but state = :#{state}"
      end
    end

    # Similar to start but should only be used to play another round when a game has ended. It transitions
    # the engine from the :game_over state into the :playing state.
    #
    # Sets the last event to be:
    #
    #   { name: :game_started, type: :continue_playing }
    #
    # @param turn [Grid::X, Grid::O] the token to have first play
    # @raise [ArgumentError] unless turn is either {Grid::X} or {Grid::O}
    # @raise [IllegalStateError] unless it's called in the :game_over state
    # @return [self]
    def continue_playing(turn)
      check_turn(turn)

      case state
      when :game_over
        handle_continue_playing(turn)
      else
        raise IllegalStateError, "must be in the :game_over state but state = :#{state}"
      end
    end

    # The exception raised by {#start}, {#stop}, {#play} and {#continue_playing} whenever
    # these methods are called and the engine is in the wrong state.
    class IllegalStateError < StandardError; end

    private

      def handle_start(turn)
        @state = :playing
        @turn = turn
        @grid.clear

        set_event(:game_started)
      end

      def handle_stop
        reset

        set_event(:game_stopped)
      end

      def handle_play(r, c)
        return set_event(:invalid_move, type: :out_of_bounds) unless Grid.contains?(r, c)
        return set_event(:invalid_move, type: :occupied) unless @grid.open?(r, c)

        @grid[r, c] = turn
        last_move = { turn: turn, r: r, c: c }

        result = Evaluator.analyze(@grid, turn)

        case result[:status]
        when :ok
          @turn = next_turn
          set_event(:next_turn, last_move: last_move)
        when :game_over
          @state = :game_over

          case result[:type]
          when :winner
            set_event(:game_over, type: :winner, last_move: last_move, details: result[:details])
          when :squashed
            set_event(:game_over, type: :squashed, last_move: last_move)
          end
        end
      end

      def handle_continue_playing(turn)
        @turn = turn
        @state = :playing
        @grid.clear

        set_event(:game_started, type: :continue_playing)
      end

      def check_turn(turn)
        raise ArgumentError, "illegal token #{turn}" unless Grid.is_token?(turn)
      end

      def reset
        @state = :init
        @turn = :nobody
        @grid.clear
      end

      def set_event(name, message = {})
        @last_event = { name: name }.merge(message)
        self
      end
  end
end
