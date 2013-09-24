require 'ostruct'

module TTT

  module AI

    def self.minimax(grid, player)
      if moves = get_moves_from_cache(grid, player)
        moves.map { |move| OpenStruct.new(row: move[0], column: move[1]) }
      else
        start_state = MaxGameState.new(grid, player)
        start_state.next_states.select { |next_state| start_state.score == next_state.score }.map(&:move)
      end
    end

    def self.get_moves_from_cache(grid, player)
      result = TTT::Evaluator.analyze(grid, player)

      case result[:status]
      when :ok
        MOVES_CACHE[grid] || MOVES_CACHE[invert_grid(grid)]
      when :game_over
        []
      else
        raise IllegalGridStatusError
      end
    end

    def self.invert_grid(grid)
      (new_grid = grid.dup).each do |r, c, val|
        new_grid[r, c] = TTT::other_token(val)
      end
    end

    def self.one_x_grid(r, c)
      TTT::Grid.new.tap do |grid|
        grid[r, c] = :x
      end
    end

    MOVES_CACHE = {
      TTT::Grid.new => [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]],

      one_x_grid(1, 1) => [[2, 2]],
      one_x_grid(1, 3) => [[2, 2]],
      one_x_grid(3, 1) => [[2, 2]],
      one_x_grid(3, 3) => [[2, 2]],

      one_x_grid(1, 2) => [[1, 1], [1, 3], [2, 2], [3, 2]],
      one_x_grid(2, 1) => [[1, 1], [2, 2], [2, 3], [3, 1]],
      one_x_grid(2, 3) => [[1, 3], [2, 1], [2, 2], [3, 3]],
      one_x_grid(3, 2) => [[1, 2], [2, 2], [3, 1], [3, 3]],

      one_x_grid(2, 2) => [[1, 1], [1, 3], [3, 1], [3, 3]]
    }

    class GameState

      attr_reader :grid, :player, :move, :next_states

      def initialize(grid, player, move = nil)
        @grid   = grid.dup
        @player = player
        @move   = move

        generate_next_states
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

      def score
        if is_terminal?
          terminal_score
        else
          non_terminal_score
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

      private

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
