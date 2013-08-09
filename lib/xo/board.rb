module TTT

  class Board

    ROWS = 3
    COLS = 3

    def initialize
      @board = Array.new(ROWS * COLS, :e)
    end

    def empty?
      !(board.include?(:x) || board.include?(:o))
    end

    def full?
      board.all? { |val| [:x, :o].include?(val) }
    end

    def free?(r, c)
      !self.class.is_token?(self[r, c])
    end

    def clear
      board.fill(:e)
    end

    def each(&block)
      (1..ROWS).each do |r|
        (1..COLS).each do |c|
          block.call(r, c, self[r, c])
        end
      end
    end

    def []=(r, c, val)
      if self.class.contains?(r, c)
        board[idx(r, c)] = val
      else
        raise IndexError
      end
    end

    def [](r, c)
      if self.class.contains?(r, c)
        board[idx(r, c)]
      else
        raise IndexError
      end
    end

    def self.contains?(r, c)
      r.between?(1, ROWS) && c.between?(1, COLS)
    end

    def self.is_token?(val)
      [:x, :o].include?(val)
    end

    def state(token)
      raise ArgumentError, token unless self.class.is_token?(token)
      raise TooManyMovesAheadError if two_or_more_moves_ahead?
      raise TwoWinnersError if two_winners?

      if winners[token]
        { state: :game_over, reason: :winner, details: winners[token] }
      elsif winners[other_token(token)]
        { state: :game_over, reason: :loser, details: winners[other_token(token)] }
      else
        if full?
          { state: :game_over, reason: :squashed }
        else
          { state: :normal }
        end
      end
    end

    private

      attr_reader :board, :winners

      # Computes the 0-based index of position (r, c) on a ROWS x COLS board.
      #
      #    c  1   2   3
      #  r
      #  1    0 | 1 | 2
      #      ---+---+---
      #  2    3 | 4 | 5
      #      ---+---+---
      #  3    6 | 7 | 8
      #
      # For e.g. idx(2, 3) is 5.
      def idx(r, c)
        COLS * (r - 1) + (c - 1)
      end

      def two_winners?
        find_winners

        winners[:x] && winners[:o]
      end

      def find_winners
        @winners = {}

        # check the rows

        if board[0] == board[1] && board[1] == board[2]
          add_winner(board[0], { where: :row, index: 1 })
        end

        if board[3] == board[4] && board[4] == board[5]
          add_winner(board[3], { where: :row, index: 2 })
        end

        if board[6] == board[7] && board[7] == board[8]
          add_winner(board[6], { where: :row, index: 3 })
        end

        # check the columns

        if board[0] == board[3] && board[3] == board[6]
          add_winner(board[0], { where: :column, index: 1 })
        end

        if board[1] == board[4] && board[4] == board[7]
          add_winner(board[1], { where: :column, index: 2 })
        end

        if board[2] == board[5] && board[5] == board[8]
          add_winner(board[2], { where: :column, index: 3 })
        end

        # check the diagonals

        if board[0] == board[4] && board[4] == board[8]
          add_winner(board[0], { where: :diagonal, index: 1 })
        end

        if board[2] == board[4] && board[4] == board[6]
          add_winner(board[2], { where: :diagonal, index: 2 })
        end
      end

      def add_winner(token, details)
        if self.class.is_token?(token)
          if winners.has_key?(token)
            winners[token] << details
          else
            winners[token] = [ details ]
          end
        end
      end

      def two_or_more_moves_ahead?
        moves_ahead >= 2
      end

      def moves_ahead
        xs = os = 0

        board.each do |t|
          xs += 1 if t == :x
          os += 1 if t == :o
        end

        (xs - os).abs
      end

      def other_token(token)
        token == :x ? :o : :x
      end
  end

  class InvalidConfiguration < StandardError; end
  class TooManyMovesAheadError < InvalidConfiguration; end
  class TwoWinnersError < InvalidConfiguration; end
end
