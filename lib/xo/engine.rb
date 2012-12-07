require 'xo/grid'

module TicTacToe

  class Engine

    attr_reader :state # :idle, :playing, :game_over
    attr_reader :turn  # :x, :o

    def initialize
      @state = :idle
      @turn  = :x
      @grid  = Grid.new
    end

    def grid
      @grid.clone
    end

    def next_turn
      { x: :o, o: :x }[@turn]
    end

    def start_playing_as_x
      start_playing :x
    end

    def start_playing_as_o
      start_playing :o
    end

    def make_move(r, c)
      raise IllegalStateError, @state unless @state == :playing

      if Grid.contains?(r, c)
        if @grid.empty?(r, c)
          @grid.send("put#{@turn}", r, c)
          status = @grid.send("#{@turn}status")

          if status[:kind] == :ok
            if status[:type] == :game_in_progress
              @turn = next_turn
              { kind: :ok, type: :next_turn, details: @turn }
            elsif status[:type] == :game_over
              @state = :game_over
              status[:details] = [@turn, status[:details]] if status[:reason] == :win
              status
            else # unknown type
              # assuming the Grid class is implemented correctly,
              # we should never reach here
              raise InternalLogicError, status[:type]
            end
          elsif status[:kind] == :error
            # we should never reach here since we
            # are enforcing the rules of the game
            raise InternalLogicError, status[:type]
          else # unknown kind
            # assuming the Grid class is implemented correctly,
            # we should never reach here
            raise InternalLogicError, status[:kind]
          end
        else
          { kind: :error, type: :cell_is_occupied, details: @grid[r, c] }
        end
      else
        { kind: :error, type: :out_of_bounds }
      end
    end

  private

    def start_playing(t)
      @state = :playing
      @turn  = t
      @grid.clear_all
    end
  end

  # Base exception for all exceptions that could be raised by the engine
  class EngineError < StandardError; end

  # Possible exceptions
  class IllegalStateError < EngineError; end
  class InternalLogicError < EngineError; end
end
