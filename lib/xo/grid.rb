module XO

  # A data structure for storing {X}'s and {O}'s in a 3x3 grid.
  #
  # The grid is structured as follows:
  #
  #        column
  #       1   2   3
  #   row
  #    1    |   |
  #      ---+---+---
  #    2    |   |
  #      ---+---+---
  #    3    |   |
  class Grid

    X = :x
    O = :o

    EMPTY = :e

    ROWS = 3
    COLS = 3

    N = ROWS * COLS

    def self.contains?(r, c)
      r.between?(1, ROWS) && c.between?(1, COLS)
    end

    def self.is_token?(k)
      k == X || k == O
    end

    def self.other_token(k)
      k == X ? O : (k == O ? X : k)
    end

    def initialize(g = '')
      @grid = from_string(g)
    end

    def initialize_copy(orig)
      @grid = orig.instance_variable_get(:@grid).dup
    end

    def empty?
      grid.all? { |k| !self.class.is_token?(k) }
    end

    def full?
      grid.all? { |k| self.class.is_token?(k) }
    end

    def []=(r, c, k)
      if self.class.contains?(r, c)
        grid[idx(r, c)] = normalize(k)
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

    def open?(r, c)
      !self.class.is_token?(self[r, c])
    end

    def clear
      grid.fill(EMPTY)
    end

    # Iterates over all the positions of this grid from left to right and top to bottom.
    #
    # @example
    #  g = Grid.new
    #  g.each do |r, c, k|
    #    puts "(#{r}, #{c}) -> #{k}"
    #  end
    def each
      (1..ROWS).each do |r|
        (1..COLS).each do |c|
          yield(r, c, self[r, c])
        end
      end
    end

    # Iterates over all the open positions of this grid from left to right and top to bottom.
    #
    # @example
    #  g = Grid.new
    #
    #  g[1, 1] = g[2, 1] = Grid::X
    #  g[2, 2] = g[3, 1] = Grid::O
    #
    #  g.each_open do |r, c|
    #    puts "(#{r}, #{c}) is open"
    #  end
    def each_open
      self.each { |r, c, _| yield(r, c) if open?(r, c) }
    end

    # Returns a string representation of this grid which can be useful for debugging.
    def inspect
      grid.map { |k| t(k) }.join
    end

    # Returns a string representation of this grid which can be useful for display.
    def to_s
      g = grid.map { |k| t(k) }

      [" #{g[0]} | #{g[1]} | #{g[2]} ",
       "---+---+---",
       " #{g[3]} | #{g[4]} | #{g[5]} ",
       "---+---+---",
       " #{g[6]} | #{g[7]} | #{g[8]} "].join("\n")
    end

    private

      attr_reader :grid

      def from_string(s)
        adjust_length(s, N).split('').map do |ch|
          normalize(ch.to_sym)
        end
      end

      def adjust_length(s, n)
        l = s.length

        if l < n
          s + ' ' * (n - l)
        elsif l > n
          s[0..n-1]
        else
          s
        end
      end

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

      NORMALIZED_TO_STRING_MAP = { X => 'x', O => 'o', EMPTY => ' ' }

      def t(k)
        NORMALIZED_TO_STRING_MAP[normalize(k)]
      end

      def normalize(k)
        self.class.is_token?(k) ? k : EMPTY
      end
  end
end
