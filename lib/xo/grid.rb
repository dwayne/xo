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
  #
  # It is important to note that if a position stores anything other than
  # {X} or {O} then that position is considered to be open.
  class Grid

    X = :x
    O = :o

    ROWS = 3
    COLS = 3

    N = ROWS * COLS

    # Determines whether or not position (r, c) is such that 1 <= r <= 3 and 1 <= c <= 3.
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    # @return [Boolean] true iff the position is contained within a 3x3 grid
    def self.contains?(r, c)
      r.between?(1, ROWS) && c.between?(1, COLS)
    end

    # Classifies what is and isn't considered to be a token.
    #
    # @param val [Object]
    # @return [Boolean] true iff val is {X} or {O}
    def self.is_token?(val)
      val == X || val == O
    end

    # Determines the other token.
    #
    # @param val [Object]
    # @return [Object] {X} given {O}, {O} given {X} or the original value
    def self.other_token(val)
      val == X ? O : (val == O ? X : val)
    end

    attr_reader :grid
    private :grid

    # Creates a new empty grid by default. You can also create a
    # prepopulated grid by passing in a string representation.
    #
    # @example
    #  g = Grid.new('xo ox   o')
    def initialize(g = '')
      @grid = from_string(g)
    end

    # Creates a copy of the given grid. Use #dup to get your copy.
    #
    # @example
    #  g = Grid.new
    #  g_copy = g.dup
    #
    # @param orig [Grid] the original grid
    # @return [Grid] a copy
    def initialize_copy(orig)
      @grid = orig.instance_variable_get(:@grid).dup
    end

    # Determines whether or not there are any tokens on the grid.
    #
    # @return [Boolean] true iff there are no tokens on the grid
    def empty?
      grid.all? { |val| !self.class.is_token?(val) }
    end

    # Determines whether or not every position on the grid has a token?
    #
    # @return [Boolean] true iff every position on the grid has a token
    def full?
      grid.all? { |val| self.class.is_token?(val) }
    end

    # Sets position (r, c) to the given value.
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    # @param val [Object]
    # @raise [IndexError] if the position is off the grid
    # @return [Object] the value it was given
    def []=(r, c, val)
      if self.class.contains?(r, c)
        grid[idx(r, c)] = self.class.is_token?(val) ? val : :e
      else
        raise IndexError, "position (#{r}, #{c}) is off the grid"
      end
    end

    # Retrieves the value at the given position (r, c).
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    # @raise [IndexError] if the position is off the grid
    # @return [Object]
    def [](r, c)
      if self.class.contains?(r, c)
        grid[idx(r, c)]
      else
        raise IndexError, "position (#{r}, #{c}) is off the grid"
      end
    end

    # Determines whether or not position (r, c) contains a token.
    #
    # @param r [Integer] the row
    # @param c [Integer] the column
    # @raise [IndexError] if the position is off the grid
    # @return true iff the position does not contain a token
    def open?(r, c)
      !self.class.is_token?(self[r, c])
    end

    # Removes all tokens from the grid.
    def clear
      grid.fill(:e)

      self
    end

    # Used for iterating over all the positions of the grid from left to right and top to bottom.
    #
    # @example
    #  g = Grid.new
    #  g.each do |r, c, val|
    #    puts "(#{r}, #{c}) -> #{val}"
    #  end
    def each
      (1..ROWS).each do |r|
        (1..COLS).each do |c|
          yield(r, c, self[r, c])
        end
      end
    end

    # Used for iterating over all the open positions of the grid from left to right and top to bottom.
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

    # Returns a string representation of the grid which may be useful
    # for debugging.
    def inspect
      grid.map { |val| t(val) }.join
    end

    # Returns a string representation of the grid which may be useful
    # for display.
    def to_s
      g = grid.map { |val| t(val) }

      [" #{g[0]} | #{g[1]} | #{g[2]} ",
       "---+---+---",
       " #{g[3]} | #{g[4]} | #{g[5]} ",
       "---+---+---",
       " #{g[6]} | #{g[7]} | #{g[8]} "].join("\n")
    end

    private

      def from_string(g)
        g = g.to_s
        l = g.length

        g = if l < N
          g + ' ' * (N - l)
        elsif l > N
          g[0..N-1]
        else
          g
        end

        g.split('').map do |ch|
          sym = ch.to_sym
          sym == X || sym == O ? sym : :e
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

      def t(val)
        self.class.is_token?(val) ? val : ' '
      end
  end
end
