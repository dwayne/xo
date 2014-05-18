require 'spec_helper'

module XO::AI

  describe GeometricGrid do

    describe "#rotate" do

      let (:grid) { GeometricGrid.new("xoooxxoxo") }

      it "correctly performs a single rotation" do
        rotated_grid = grid.rotate

        rotated_grid.inspect.must_equal "ooxxxooxo"
      end

      it "returns the original on the 4th rotation" do
        original_grid = grid.rotate.rotate.rotate.rotate

        original_grid.same?(grid).must_equal true
      end
    end

    describe "#reflect" do

      let (:grid) { GeometricGrid.new("oxxxoooxo") }

      it "correctly performs a single reflection" do
        reflected_grid = grid.reflect

        reflected_grid.inspect.must_equal "xxoooxoxo"
      end

      it "returns the original on the 2nd reflection" do
        original_grid = grid.reflect.reflect

        original_grid.same?(grid).must_equal true
      end
    end

    describe "#same?" do

      it "returns true iff two grids have the same occupied positions" do
        a = GeometricGrid.new('x')
        b = GeometricGrid.new('  x')

        a.same?(a).must_equal true
        a.same?(b).must_equal false # but they are equivalent
      end
    end

    describe "#equivalent?" do

      it "correctly determines equivalent grids" do
        a = GeometricGrid.new('x')

        ['  x', '        x', '      x'].each do |g|
          a.equivalent?(GeometricGrid.new(g)).must_equal true
        end

        b = GeometricGrid.new(' x')

        ['     x', '       x', '   x'].each do |g|
          b.equivalent?(GeometricGrid.new(g)).must_equal true
        end

        c = GeometricGrid.new('xo')

        [' ox', '     o  x', '      xo', 'x  o'].each do |g|
          c.equivalent?(GeometricGrid.new(g)).must_equal true
        end
      end

      it "can only determine the equivalence of two geometric grids" do
        a = GeometricGrid.new('x')
        b = XO::Grid.new('  x')

        a.equivalent?(b).must_equal false
      end
    end

    describe "#==" do

      it "is reflexive, symmetric and transitive" do
        a = GeometricGrid.new('x')
        b = GeometricGrid.new('  x')
        c = GeometricGrid.new('        x')

        # reflexive, not quite since we didn't test for all a
        a.must_equal a

        # symmetric
        a.must_equal b
        b.must_equal a

        # transitive
        b.must_equal c
        a.must_equal c
      end

      describe "#== and #eql?" do

        it "must be the case that if two geometric grid are #== then they are also #eql?" do
          a = GeometricGrid.new('x')
          b = GeometricGrid.new('  x')

          a.eql?(b).must_equal true
        end
      end
    end

    describe "#hash" do

      it "must return the same hash for equal geometric grids" do
        a = GeometricGrid.new('     x')
        b = GeometricGrid.new('       x')

        a.hash.must_equal b.hash
      end
    end

    describe "when used within a hash" do

      it "must be the case that equivalent grids map to the same key" do
        a = GeometricGrid.new('x')
        b = GeometricGrid.new('  x')

        hash = {}
        hash[a] = :any_value

        hash[b].must_equal :any_value
      end
    end
  end
end
