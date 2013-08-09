require_relative '../spec_helper'
require 'xo/game/playing_state'

module TTT::Game

  describe PlayingState do

    let(:state) { PlayingState.new(Object.new) }

    describe '#play' do

      it 'sends #handle_play to the engine' do
        state.engine = ::MiniTest::Mock.new
        state.engine.expect :handle_play, :retval, [:r, :c]

        state.play(:r, :c)

        state.engine.verify
      end
    end

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

    describe '#continue_playing' do

      it 'raises NotImplementedError' do
        proc { state.continue_playing(:anything) }.must_raise NotImplementedError
      end
    end
  end
end
