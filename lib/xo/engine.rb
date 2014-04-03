require 'observer'
require 'ostruct'

require 'xo/grid'
require 'xo/evaluator'

module XO

  class Engine
    include Observable

    attr_reader :turn, :state

    def initialize
      @grid = Grid.new
      @turn = :nobody
      @state = :idle
    end

    def grid
      @grid.dup
    end

    def next_turn
      XO.other_token(turn)
    end

    def start(player)
      raise ArgumentError, "unknown player #{player}" unless XO.is_player?(player)

      case state
      when :idle
        handle_start(player)
      else
        raise NotImplementedError
      end

      self
    end

    def stop
      case state
      when :playing, :game_over
        handle_stop
      else
        raise NotImplementedError
      end

      self
    end

    def play(r, c)
      case state
      when :playing
        handle_play(r.to_i, c.to_i)
      else
        raise NotImplementedError
      end

      self
    end

    def continue_playing(player)
      raise ArgumentError, "unknown player #{player}" unless XO.is_player?(player)

      case state
      when :game_over
        handle_continue_playing(player)
      else
        raise NotImplementedError
      end

      self
    end

    private

      attr_writer :turn, :state

      def handle_start(player)
        self.turn = player
        self.state = :playing
        @grid.clear

        send_event(:game_started, who: player)
      end

      def handle_stop
        self.state = :idle

        send_event(:game_stopped)
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
              send_event(:next_turn, who: turn, last_played_at: last_played_at)
            when :game_over
              self.state = :game_over

              case result[:type]
              when :winner
                send_event(:game_over, type: :winner, who: turn, last_played_at: last_played_at, details: result[:details])
              when :squashed
                send_event(:game_over, type: :squashed, who: turn, last_played_at: last_played_at)
              end
            end
          else
            send_event(:invalid_move, type: :occupied)
          end
        else
          send_event(:invalid_move, type: :out_of_bounds)
        end
      end

      def handle_continue_playing(player)
        self.turn = player
        self.state = :playing
        @grid.clear

        send_event(:continue_playing, who: player)
      end

      def send_event(name, message = {})
        changed
        notify_observers({ event: name }.merge(message))
      end
  end
end
