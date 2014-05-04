require 'forwardable'

require 'xo/grid'

module XO

  module AI

    # A geometric grid is like a Tic-tac-toe grid ({XO::Grid}) but with the added benefit
    # that various geometric transformations (rotation and reflection) can be applied. It
    # defines a concept of equivalence under these transformations. Geometric grids can be
    # checked for equality and they define a hash function that allows them to be used in
    # a Hash.
    class GeometricGrid
      extend Forwardable

      # Creates a new empty geometric grid by default. You can also create a
      # prepopulated grid by passing in a string representation.
      #
      # @example
      #  g = GeometricGrid.new('xo ox   o')
      def initialize(g = '')
        @grid = Grid.new(g)
      end

      # Creates a copy of the given geometric grid. Use #dup to get your copy.
      #
      # @example
      #  g = GeometricGrid.new
      #  g_copy = g.dup
      #
      # @param orig [GeometricGrid] the original grid
      # @return [GeometricGrid] a copy
      def initialize_copy(orig)
        @grid = orig.instance_variable_get(:@grid).dup
      end

      # Returns a copy of the underlying non-geometric grid.
      def standard_grid
        @grid.dup
      end

      def_delegators :@grid,
        :empty?, :full?,
        :[]=, :[],
        :open?,
        :clear,
        :each, :each_open,
        :inspect, :to_s

      # Rotate the geometric grid clockwise by 90 degrees.
      #
      #    0 | 1 | 2          6 | 3 | 0
      #   ---+---+---        ---+---+---
      #    3 | 4 | 5    =>    7 | 4 | 1
      #   ---+---+---        ---+---+---
      #    6 | 7 | 8          8 | 5 | 2
      #
      # @return [GeometricGrid]
      def rotate
        g = GeometricGrid.new

        g[1, 1] = self[3, 1]
        g[1, 2] = self[2, 1]
        g[1, 3] = self[1, 1]

        g[2, 1] = self[3, 2]
        g[2, 2] = self[2, 2]
        g[2, 3] = self[1, 2]

        g[3, 1] = self[3, 3]
        g[3, 2] = self[2, 3]
        g[3, 3] = self[1, 3]

        g
      end

      # Reflect the geometric grid in its vertical axis.
      #
      #    0 | 1 | 2          2 | 1 | 0
      #   ---+---+---        ---+---+---
      #    3 | 4 | 5    =>    5 | 4 | 3
      #   ---+---+---        ---+---+---
      #    6 | 7 | 8          8 | 7 | 6
      #
      # @return [GeometricGrid]
      def reflect
        g = GeometricGrid.new

        g[1, 1] = self[1, 3]
        g[1, 2] = self[1, 2]
        g[1, 3] = self[1, 1]

        g[2, 1] = self[2, 3]
        g[2, 2] = self[2, 2]
        g[2, 3] = self[2, 1]

        g[3, 1] = self[3, 3]
        g[3, 2] = self[3, 2]
        g[3, 3] = self[3, 1]

        g
      end

      # Determines whether or not this geometric grid has the same
      # occupied positions as the given grid.
      #
      # @note The other grid need not be geometric. It just needs to
      #  respond to #inspect, which every object does.
      #
      # @param other [#inspect]
      # @return [Boolean]
      def same?(other)
        self.inspect == other.inspect
      end

      # Determines whether or not this geometric grid is equivalent to
      # the given geometric grid.
      #
      # Two geometric grids are considered equivalent iff one is a
      # rotation or reflection of the other.
      #
      # @param other [GeometricGrid] the other grid
      # @return [Boolean]
      def equivalent?(other)
        return false unless other.instance_of?(self.class)

        transformations.any? { |grid| other.same?(grid) }
      end

      # Redefines equality for a geometric grid.
      #
      # Two geometric grids are equal iff they are equivalent.
      #
      # @return [Boolean]
      def ==(other)
        equivalent?(other)
      end
      alias_method :eql?, :==

      # Required if you want to be able to use a geometric grid as a key in a Hash.
      #
      # Equivalent grids must have the same hash.
      #
      # @return [Integer]
      def hash
        transformations.map(&:inspect).sort.uniq.join.hash
      end

      private

        def rotations
          [self, rot90, rot180, rot270]
        end

        def rot90
          rotate
        end

        def rot180
          rotate.rotate
        end

        def rot270
          rotate.rotate.rotate
        end

        def reflections
          [self, reflect]
        end

        def transformations
          rotations + rotations.map(&:reflect)
        end
    end
  end
end
