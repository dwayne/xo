module TTT

  class Grid

    ROWS = 3
    COLS = 3

    def self.contains?(r, c)
      r.between?(1, ROWS) && c.between?(1, COLS)
    end

    def initialize
      @grid = Array.new(ROWS * COLS, :e)
    end

    def initialize_copy(orig)
      @grid = orig.instance_variable_get(:@grid).dup
    end

    def []=(r, c, val)
      if self.class.contains?(r, c)
        grid[idx(r, c)] = val
      else
        raise IndexError, "position (#{r}, #{c}) is off the grid"
      end
    end

    def [](r, c)
      if self.class.contains?(r, c)
        grid[idx(r, c)]
      else
        raise IndexError, "position (#{r}, #{c}) is off the grid"
      end
    end

    def empty?
      grid.all? { |val| !TTT.is_token?(val) }
    end

    def full?
      grid.all? { |val| TTT.is_token?(val) }
    end

    def free?(r, c)
      !TTT.is_token?(self[r, c])
    end

    def clear
      grid.fill(:e)
    end

    def each
      (1..ROWS).each do |r|
        (1..COLS).each do |c|
          yield(r, c, self[r, c])
        end
      end
    end

    private

      attr_reader :grid

      # Computes the 0-based index of position (r, c) on a 3x3 grid.
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
