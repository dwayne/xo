require 'ostruct'
require 'xo/evaluator'

module XO::AI

  def self.minimax(grid, player)
    state = MaxGameState.new(grid, player)
    moves = state.next_states.select { |next_state| state.score == next_state.score }.map(&:move)

    OpenStruct.new(start_state: state, moves: moves)
  end

  class GameState

    attr_reader :grid, :player, :move, :next_states

    def initialize(grid, player, move = nil)
      @grid   = grid.dup
      @player = player
      @move   = move

      generate_next_states
    end

    def result
      @result ||= XO::Evaluator.analyze(grid, player)
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
          grid.each_free do |r, c|
            next_grid = grid.dup
            next_grid[r, c] = player

            @next_states << next_game_state(next_grid, XO.other_player(player), XO::Position.new(r, c))
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
