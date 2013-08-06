require_relative 'spec_helper'
require_relative '../lib/xo/engine'
require_relative '../lib/xo/idle_state'

require 'ostruct'

module TTT

  describe IdleState do

    before do
      null_listener = OpenStruct.new
      def null_listener.handle_event(e); end

      @engine = Engine.new(null_listener)
      @idle_state = @engine.idle_state
    end

    describe '#start' do

      it 'clears the board' do
        @engine.board = ::MiniTest::Mock.new
        @engine.board.expect :clear, :retval
        @idle_state.start(:any_value)
        @engine.board.verify
      end

      it 'sets turn to the value given as its argument' do
        @idle_state.start(:any_value)
        @engine.turn.must_equal :any_value
      end

      it 'changes the state to the playing state' do
        @idle_state.start(:any_value)
        @engine.state.must_equal @engine.playing_state
      end

      it 'notifies the listener' do
        @engine.listener = ::MiniTest::Mock.new
        @engine.listener.expect :handle_event, :retval, [Object]
        @idle_state.start(:any_value)
        @engine.listener.verify
      end
    end

    describe '#stop' do

      it 'should raise NotImplementedError' do
        proc { @idle_state.stop }.must_raise NotImplementedError
      end
    end

    describe '#play' do

      it 'should raise NotImplementedError' do
        proc { @idle_state.play(:r, :c) }.must_raise NotImplementedError
      end
    end

    describe '#continue_playing' do

      it 'should raise NotImplementedError' do
        proc { @idle_state.continue_playing(:t) }.must_raise NotImplementedError
      end
    end
  end
end
