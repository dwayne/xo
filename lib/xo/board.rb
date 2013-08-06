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
      ![:x, :o].include?(self[r, c])
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

    private

      attr_reader :board

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
  end
end
