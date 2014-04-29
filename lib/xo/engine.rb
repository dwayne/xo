require 'ostruct'

require 'xo/grid'
require 'xo/evaluator'

module XO

  class Engine

    attr_reader :turn, :state, :last_event

    def initialize
      @grid = Grid.new
      @turn = :nobody
      @state = :idle
      @last_event = nil
    end

    def grid
      @grid.dup
    end

    def next_turn
      XO.other_player(turn)
    end

    def start(player)
      raise ArgumentError, "unknown player #{player}" unless XO.is_player?(player)

      case state
      when :idle
        handle_start(player)
      else
        raise NotImplementedError
      end
    end

    def stop
      case state
      when :playing, :game_over
        handle_stop
      else
        raise NotImplementedError
      end
    end

    def play(r, c)
      case state
      when :playing
        handle_play(r.to_i, c.to_i)
      else
        raise NotImplementedError
      end
    end

    def continue_playing(player)
      raise ArgumentError, "unknown player #{player}" unless XO.is_player?(player)

      case state
      when :game_over
        handle_continue_playing(player)
      else
        raise NotImplementedError
      end
    end

    private

      attr_writer :turn, :state, :last_event

      def handle_start(player)
        self.turn = player
        self.state = :playing
        @grid.clear

        make_event(:game_started, who: player)
      end

      def handle_stop
        self.state = :idle

        make_event(:game_stopped)
      end

      def handle_play(r, c)
        if Grid.contains?(r, c)
          if @grid.free?(r, c)
            @grid[r, c] = turn
            last_played_at = OpenStruct.new(row: r, col: c)

            result = Evaluator.analyze(@grid, turn)

            case result[:status]
            when :ok
              self.turn = next_turn
              make_event(:next_turn, who: turn, last_played_at: last_played_at)
            when :game_over
              self.state = :game_over

              case result[:type]
              when :winner
                make_event(:game_over, type: :winner, who: turn, last_played_at: last_played_at, details: result[:details])
              when :squashed
                make_event(:game_over, type: :squashed, who: turn, last_played_at: last_played_at)
              end
            end
          else
            make_event(:invalid_move, type: :occupied)
          end
        else
          make_event(:invalid_move, type: :out_of_bounds)
        end
      end

      def handle_continue_playing(player)
        self.turn = player
        self.state = :playing
        @grid.clear

        make_event(:continue_playing, who: player)
      end

      def make_event(name, message = {})
        self.last_event = { event: name }.merge(message)
      end
  end
end
