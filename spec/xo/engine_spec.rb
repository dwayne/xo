require 'spec_helper'

module XO

  describe Engine do

    let (:engine) { Engine.new }

    describe 'initial state' do

      it 'has an empty grid' do
        engine.grid.empty?.must_equal true
      end

      it "is nobody's turn" do
        engine.turn.must_equal :nobody
      end

      it 'is in the idle state' do
        engine.state.must_equal :idle
      end
    end

    describe '#grid' do

      it 'returns a copy' do
        grid = engine.grid
        grid[1, 1] = X

        # FIXME: How else can I test this requirement? I don't like that the test
        # depends on knowing the name of the internal private instance variable.
        engine.instance_variable_get(:@grid).empty?.must_equal true
      end
    end

    describe 'a single round of play' do

      it 'works as follows' do
        engine.start(X)
        engine.play(1, 1)
        engine.play(2, 1)
        engine.play(1, 2)
        engine.play(2, 2)

        e = engine.play(1, 3)

        e[:event].must_equal :game_over
        e[:type].must_equal :winner
        e[:who].must_equal X
      end
    end
  end
end
