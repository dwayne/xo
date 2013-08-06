require_relative 'spec_helper'
require_relative '../lib/xo/engine'

module TTT

  describe Engine do

    before do
      @engine = Engine.new
    end

    it 'should respond to listener' do
      @engine.must_respond_to :listener
    end

    it 'should respond to turn' do
      @engine.must_respond_to :turn
    end

    it 'should respond to board' do
      @engine.must_respond_to :board
    end

    it 'should respond to referee' do
      @engine.must_respond_to :referee
    end

    it 'must start in the idle state' do
      @engine.state.must_equal @engine.idle_state
    end

    describe 'its state transition methods' do

      before do
        @state = @engine.state = ::MiniTest::Mock.new
      end

      describe '#start' do

        it 'invokes #start on the state when called with an :x' do
          @state.expect :start, :retval, [:x]
          @engine.start(:x)
          @state.verify
        end

        it 'invokes #start on the state when called with an :o' do
          @state.expect :start, :retval, [:o]
          @engine.start(:o)
          @state.verify
        end

        it 'raises ArgumentError when called with neither :x nor :o' do
          proc { @engine.start(:neither_x_nor_o) }.must_raise ArgumentError
        end
      end

      describe '#stop' do

        it 'invokes #stop on the state when called' do
          @state.expect :stop, :retval
          @engine.stop
          @state.verify
        end
      end

      describe '#play' do

        it 'invokes #play on the state when called' do
          @state.expect :play, :retval, [1, 1]
          @engine.play(1, 1)
          @state.verify
        end
      end

      describe '#continue_playing' do

        it 'invokes #continue_playing on the state when called with an :x' do
          @state.expect :continue_playing, :retval, [:x]
          @engine.continue_playing(:x)
          @state.verify
        end

        it 'invokes #continue_playing on the state when called with an :o' do
          @state.expect :continue_playing, :retval, [:o]
          @engine.continue_playing(:o)
          @state.verify
        end

        it 'raises ArgumentError when called with neither :x nor :o' do
          proc { @engine.continue_playing(:neither_x_nor_o) }.must_raise ArgumentError
        end
      end
    end

    describe 'its states' do

      it 'has an idle state' do
        @engine.idle_state.wont_be_nil
      end

      it 'has a playing state' do
        @engine.playing_state.wont_be_nil
      end

      it 'has a game over state' do
        @engine.game_over_state.wont_be_nil
      end
    end
  end
end
