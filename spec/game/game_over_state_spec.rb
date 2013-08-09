require_relative '../spec_helper'
require 'xo/game/game_over_state'

module TTT::Game

  describe GameOverState do

    let(:state) { GameOverState.new(Object.new) }

    describe '#stop' do

      it 'sends #handle_stop to the engine' do
        state.engine = ::MiniTest::Mock.new
        state.engine.expect :handle_stop, :retval

        state.stop

        state.engine.verify
      end
    end

    describe '#continue_playing' do

      it 'sends #handle_continue_playing to the engine' do
        state.engine = ::MiniTest::Mock.new
        state.engine.expect :handle_continue_playing, :retval, [:t]

        state.continue_playing(:t)

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
  end
end
