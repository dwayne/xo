require 'ostruct'

module TTT

  module AI

    def self.minimax(grid, player)
      start_state = MaxGameState.new(grid, player)
      start_state.next_states.select { |next_state| start_state.score == next_state.score }.map(&:move)
    end

    class GameState

      attr_reader :grid, :player, :move, :next_states

      def initialize(grid, player, move = nil)
        @grid   = grid.dup
        @player = player
        @move   = move

        clear_cache!
        generate_next_states unless find_in_cache
      end

      def result
        @result ||= TTT::Evaluator.analyze(grid, player)
      end

      def is_terminal?
        case result[:status]
        when :ok
          false
        when :game_over
          true
        else
          raise IllegalGridStatusError
        end
      end

      def scores
        next_states.map(&:score)
      end
      protected :scores

      def score
        return @score if defined? @score

        @score =
          if (state = find_in_cache) && state != self
            state.score
          else
            if is_terminal?
              terminal_score
            else
              non_terminal_score
            end
          end
      end

      def terminal_score
        raise NotImplementedError
      end

      def non_terminal_score
        raise NotImplementedError
      end

      def next_game_state(next_grid, other_player, move)
        raise NotImplementedError
      end

      def clear_cache!
        @@cache = {} if move.nil?
      end

      private

        def find_in_cache
          unless defined? @cached_state
            @cached_state = nil

            (1..3).each do |n|
              rotated_grid = self.class.rotate_grid(grid, n)

              if @@cache.key?(rotated_grid)
                @cached_state = @@cache[rotated_grid]
                break
              end
            end
          end

          @cached_state
        end

        def self.rotate_grid(grid, n)
          if n == 0
            grid
          else
            new_grid = TTT::Grid.new

            new_grid[1, 1] = grid[1, 3]
            new_grid[1, 2] = grid[2, 3]
            new_grid[1, 3] = grid[3, 3]

            new_grid[2, 1] = grid[1, 2]
            new_grid[2, 2] = grid[2, 2]
            new_grid[2, 3] = grid[3, 2]

            new_grid[3, 1] = grid[1, 1]
            new_grid[3, 2] = grid[2, 1]
            new_grid[3, 3] = grid[3, 1]

            rotate_grid(new_grid, n-1)
          end
        end

        def generate_next_states
          @next_states = []

          unless is_terminal?
            grid.each do |r, c, _|
              if grid.free?(r, c)
                next_grid = grid.dup
                next_grid[r, c] = player

                @next_states << next_game_state(next_grid, TTT.other_player(player), OpenStruct.new(row: r, column: c))
              end
            end
          end

          @@cache[grid] = self
        end
    end

    class MaxGameState < GameState

      def next_game_state(next_grid, other_player, move)
        MinGameState.new(next_grid, other_player, move)
      end

      def terminal_score
        case result[:type]
        when :winner
          1
        when :loser
          -1
        when :squashed
          0
        end
      end

      def non_terminal_score
        scores.max
      end
    end

    class MinGameState < GameState

      def next_game_state(next_grid, other_player, move)
        MaxGameState.new(next_grid, other_player, move)
      end

      def terminal_score
        case result[:type]
        when :winner
          -1
        when :loser
          1
        when :squashed
          0
        end
      end

      def non_terminal_score
        scores.min
      end
    end

    class IllegalGridStatusError < StandardError; end
  end
end
