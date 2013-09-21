module TTT

  module Evaluator

    def self.analyze(grid, player)
      @grid = grid
      @player = player

      perform_analysis
    end

    private

      class << self
        attr_reader :grid, :player, :winners
      end

      def self.perform_analysis
        return { status: :error, type: :too_many_moves_ahead } if two_or_more_moves_ahead?

        find_winners

        if two_winners?
          { status: :error, type: :two_winners }
        elsif winners[player]
          { status: :game_over, type: :winner, details: winners[player] }
        elsif winners[other_player]
          { status: :game_over, type: :loser, details: winners[other_player] }
        else
          if grid.full?
            { status: :game_over, type: :squashed }
          else
            { status: :ok }
          end
        end
      end

      def self.two_or_more_moves_ahead?
        moves_ahead >= 2
      end

      def self.moves_ahead
        xs = os = 0

        grid.each do |_, _, val|
          xs += 1 if val == TTT::X
          os += 1 if val == TTT::O
        end

        (xs - os).abs
      end

      def self.find_winners
        @winners = {}

        # check rows
        if grid[1, 1] == grid[1, 2] && grid[1, 2] == grid[1, 3]
          add_winner(grid[1, 1], { where: :row, index: 1, positions: [[1, 1], [1, 2], [1, 3]] })
        end

        if grid[2, 1] == grid[2, 2] && grid[2, 2] == grid[2, 3]
          add_winner(grid[2, 1], { where: :row, index: 2, positions: [[2, 1], [2, 2], [2, 3]] })
        end

        if grid[3, 1] == grid[3, 2] && grid[3, 2] == grid[3, 3]
          add_winner(grid[3, 1], { where: :row, index: 3, positions: [[3, 1], [3, 2], [3, 3]] })
        end

        # check columns
        if grid[1, 1] == grid[2, 1] && grid[2, 1] == grid[3, 1]
          add_winner(grid[1, 1], { where: :column, index: 1, positions: [[1, 1], [2, 1], [3, 1]] })
        end

        if grid[1, 2] == grid[2, 2] && grid[2, 2] == grid[3, 2]
          add_winner(grid[1, 2], { where: :column, index: 2, positions: [[1, 2], [2, 2], [3, 2]] })
        end

        if grid[1, 3] == grid[2, 3] && grid[2, 3] == grid[3, 3]
          add_winner(grid[1, 3], { where: :column, index: 3, positions: [[1, 3], [2, 3], [3, 3]] })
        end

        # check diagonals
        if grid[1, 1] == grid[2, 2] && grid[2, 2] == grid[3, 3]
          add_winner(grid[1, 1], { where: :diagonal, index: 1, positions: [[1, 1], [2, 2], [3, 3]] })
        end

        if grid[1, 3] == grid[2, 2] && grid[2, 2] == grid[3, 1]
          add_winner(grid[1, 3], { where: :diagonal, index: 2, positions: [[1, 3], [2, 2], [3, 1]] })
        end
      end

      def self.add_winner(who, details)
        if TTT.is_token?(who)
          if winners.key?(who)
            winners[who] << details
          else
            winners[who] = [details]
          end
        end
      end

      def self.two_winners?
        winners[TTT::X] && winners[TTT::O]
      end

      def self.other_player
        player == TTT::X ? TTT::O : TTT::X
      end
  end
end
