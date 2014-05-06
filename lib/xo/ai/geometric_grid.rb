require 'xo/grid'

module XO

  module AI

    # A geometric grid is a Tic-tac-toe grid ({XO::Grid}) with the added benefit that
    # various geometric transformations (rotation and reflection) can be applied. It
    # defines a concept of equivalence under these transformations. Geometric grids can
    # be checked for equality and they define a hash function that allows them to be
    # used as keys within a Hash.
    class GeometricGrid < XO::Grid

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
        GeometricGrid.new(
          "#{self[3, 1]}#{self[2, 1]}#{self[1, 1]}" +
          "#{self[3, 2]}#{self[2, 2]}#{self[1, 2]}" +
          "#{self[3, 3]}#{self[2, 3]}#{self[1, 3]}"
        )
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
        GeometricGrid.new(
          "#{self[1, 3]}#{self[1, 2]}#{self[1, 1]}" +
          "#{self[2, 3]}#{self[2, 2]}#{self[2, 1]}" +
          "#{self[3, 3]}#{self[3, 2]}#{self[3, 1]}"
        )
      end

      # Determines whether or not this geometric grid has the same
      # occupied positions as the given geometric grid.
      #
      # @param other [GeometricGrid]
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

        def transformations
          rotations + rotations.map(&:reflect)
        end

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
    end
  end
end
