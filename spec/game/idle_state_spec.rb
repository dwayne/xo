require_relative '../spec_helper'
require 'xo/game/idle_state'

module TTT::Game

  describe IdleState do

    let(:state) { IdleState.new(Object.new) }

    describe '#start' do

      it 'sends #handle_start to the engine' do
        state.engine = ::MiniTest::Mock.new
        state.engine.expect :handle_start, :retval, [:anything]

        state.start(:anything)

        state.engine.verify
      end
    end

    describe '#stop' do

      it 'should raise NotImplementedError' do
        proc { state.stop }.must_raise NotImplementedError
      end
    end

    describe '#play' do

      it 'should raise NotImplementedError' do
        proc { state.play(:r, :c) }.must_raise NotImplementedError
      end
    end

    describe '#continue_playing' do

      it 'should raise NotImplementedError' do
        proc { state.continue_playing(:t) }.must_raise NotImplementedError
      end
    end
  end
end
