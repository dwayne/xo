module TicTacToe

  class Grid

    # Dimensions
    ROWS = 3 # the number of rows
    COLS = 3 # the number of columns

    def initialize
      @grid = Array.new(ROWS * COLS, :e)
    end

    def [](r, c)
      if Grid.contains?(r, c)
        @grid[idx r, c]
      else
        raise IndexError
      end
    end

    def empty?(r, c)
      self[r, c] == :e
    end

    def putx(r, c)
      self[r, c] = :x
      self
    end

    def puto(r, c)
      self[r, c] = :o
      self
    end

    def clear(r, c)
      self[r, c] = :e
      self
    end

    def clear_all
      @grid.fill :e
      self
    end

    # returns the state of this grid assuming 'X' made the last move
    def xstatus
      status :x
    end

    # returns the state of this grid assuming 'O' made the last move
    def ostatus
      status :o
    end

    def to_s
      @grid.join('')
    end

    def self.contains?(r, c)
      r.between?(1, ROWS) and c.between?(1, COLS)
    end

  private

    # returns the state of this grid assuming t (where t represents 'X' or 'O') made the last move
    def status(t)
      es, xs, os = count_tokens

      xo = xs - os

      # Bit by the bug: http://blog.jayfields.com/2007/08/ruby-operator-precedence-of-and-which.html
      # could_have_made_last_move = (t == :x and xo.between?(0, 1)) or (t == :o and xo.between?(-1, 0))
      #
      # To reproduce:
      #   1. uncomment the line above and comment the line below
      #   2. require './grid'
      #   3. g = TicTacToe::Grid.new
      #   4. g.ostatus == { kind: :error, reason: :did_not_make_last_move }
      #
      # However, g.ostatus should equal { kind: :ok, type: :game_in_progress }.
      #
      # Switching to && and || fixes the bug.
      could_have_made_last_move = (t == :x && xo.between?(0, 1)) || (t == :o && xo.between?(-1, 0))

      if could_have_made_last_move
        winning_positions = find_winning_positions t
        if winning_positions.empty?
          if es == 0
            { kind: :ok, type: :game_over, reason: :squashed }
          else
            { kind: :ok, type: :game_in_progress }
          end
        else
          { kind: :ok, type: :game_over, reason: :win, details: winning_positions }
        end
      else
        { kind: :error, reason: xo.abs > 1 ? :illegal_configuration : :did_not_make_last_move }
      end
    end

    def count_tokens
      es = xs = os = 0
      @grid.each do |t|
        es += 1 if t == :e
        xs += 1 if t == :x
        os += 1 if t == :o
      end
      [es, xs, os]
    end

    def find_winning_positions(t)
      matchers = [
        # match rows
        [Regexp.new("\\A#{t}#{t}#{t}......\\Z"), { row: 1 }],
        [Regexp.new("\\A...#{t}#{t}#{t}...\\Z"), { row: 2 }],
        [Regexp.new("\\A......#{t}#{t}#{t}\\Z"), { row: 3 }],

        # match columns
        [Regexp.new("\\A#{t}..#{t}..#{t}..\\Z"), { col: 1 }],
        [Regexp.new("\\A.#{t}..#{t}..#{t}.\\Z"), { col: 2 }],
        [Regexp.new("\\A..#{t}..#{t}..#{t}\\Z"), { col: 3 }],

        # match diagonals
        [Regexp.new("\\A#{t}...#{t}...#{t}\\Z"), { diag: 1 }],
        [Regexp.new("\\A..#{t}.#{t}.#{t}..\\Z"), { diag: 2 }]
      ]

      sig = to_s
      matchers.select { |x| sig =~ x[0] }.map { |x| x[1] }
    end

    def []=(r, c, t)
      if Grid.contains?(r, c)
        @grid[idx r, c] = t
      else
        raise IndexError
      end
    end

    # computes the 0-based index of position (r, c) in a ROWSxCOLS grid
    #
    #    c  1   2   3
    #  r
    #  1    0 | 1 | 2
    #      ---+---+---
    #  2    3 | 4 | 5
    #      ---+---+---
    #  3    6 | 7 | 8
    #
    # e.g. idx(2, 3) is 5
    def idx(r, c)
      COLS * (r - 1) + (c - 1)
    end
  end
end
