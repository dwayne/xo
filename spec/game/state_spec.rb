require_relative '../spec_helper'
require 'xo/game/state'

module TTT::Game

  describe State do

    let(:state) { State.new(Object.new) }

    describe '#stop' do

      it 'sends #handle_stop to the engine' do
        state.engine = ::MiniTest::Mock.new
        state.engine.expect :handle_stop, :retval

        state.stop

        state.engine.verify
      end
    end

    describe '#start' do

      it 'raises NotImplementedError' do
        proc { state.start(:anything) }.must_raise NotImplementedError
      end
    end

    describe '#play' do

      it 'raises NotImplementedError' do
        proc { state.play(:r, :c) }.must_raise NotImplementedError
      end
    end

    describe '#continue_playing' do

      it 'raises NotImplementedError' do
        proc { state.continue_playing(:anything) }.must_raise NotImplementedError
      end
    end
  end
end
