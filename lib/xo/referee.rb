module TTT

  class Referee

    attr_reader :board

    def initialize(board)
      @board = board
    end

    def check_status(token)
      raise ArgumentError, token unless [:x, :o].include?(token)
      raise IllegalBoardConfiguration, 'too many moves ahead' if too_many_moves_ahead?
      raise IllegalBoardConfiguration, 'too many winners' if too_many_winners?

      if winners[token]
        { event: :game_over, message: { type: :winner, details: winners[token] } }
      elsif winners[other_token(token)]
        { event: :game_over, message: { type: :loser, details: winners[other_token(token)] } }
      else
        if board.full?
          { event: :game_over, message: { type: :squashed } }
        else
          { event: :game_still_in_progress }
        end
      end
    end

    private

      attr_reader :board, :winners

      def find_winners
        @winners = {}

        # check the rows

        if board[1, 1] == board[1, 2] && board[1, 2] == board[1, 3]
          add_winner(board[1, 1], { where: :row, index: 1 })
        end

        if board[2, 1] == board[2, 2] && board[2, 2] == board[2, 3]
          add_winner(board[2, 1], { where: :row, index: 2 })
        end

        if board[3, 1] == board[3, 2] && board[3, 2] == board[3, 3]
          add_winner(board[3, 1], { where: :row, index: 3 })
        end

        # check the columns

        if board[1, 1] == board[2, 1] && board[2, 1] == board[3, 1]
          add_winner(board[1, 1], { where: :col, index: 1 })
        end

        if board[1, 2] == board[2, 2] && board[2, 2] == board[3, 2]
          add_winner(board[1, 2], { where: :col, index: 2 })
        end

        if board[1, 3] == board[2, 3] && board[2, 3] == board[3, 3]
          add_winner(board[1, 3], { where: :col, index: 3 })
        end

        # check the diagonals

        if board[1, 1] == board[2, 2] && board[2, 2] == board[3, 3]
          add_winner(board[1, 1], { where: :diagonal, index: 1 })
        end

        if board[1, 3] == board[2, 2] && board[2, 2] == board[1, 3]
          add_winner(board[1, 3], { where: :diagonal, index: 2 })
        end
      end

      def add_winner(token, details)
        if [:x, :o].include?(token)
          if winners.has_key?(token)
            winners[token] << details
          else
            winners[token] = [ details ]
          end
        end
      end

      def too_many_winners?
        find_winners

        winners[:x] && winners[:o]
      end

      def too_many_moves_ahead?
        xs, os = count_tokens
        moves_ahead = (xs - os).abs

        !moves_ahead.between?(0, 1)
      end

      def count_tokens
        xs = os = 0
        board.each do |r, c, t|
          xs += 1 if t == :x
          os += 1 if t == :o
        end
        [xs, os]
      end

      def other_token(token)
        token == :x ? :o : :x
      end
  end

  class IllegalBoardConfiguration < StandardError; end
end
