require_relative '../spec_helper'
require 'xo/game/engine'

module TTT::Game

  describe Engine do

    let(:engine) {
      listener = Object.new
      def listener.handle_event(e); end

      Engine.new(listener: listener)
    }

    describe 'when it is newly created' do

      it "is nobody's turn" do
        engine.turn.must_equal :nobody
      end

      it 'is in the idle state' do
        engine.state.must_equal engine.idle_state
      end
    end

    describe '#next_turn' do

      it 'returns :o when turn is :x' do
        engine.turn = :x
        engine.next_turn.must_equal :o
      end

      it 'returns :x when turn is :o' do
        engine.turn = :o
        engine.next_turn.must_equal :x
      end

      it 'returns :nobody when turn is :nobody' do
        engine.next_turn.must_equal :nobody
      end
    end

    describe '#send_event' do

      before do
        engine.listener = ::MiniTest::Mock.new
      end

      describe 'when called without a message' do

        it "sends just the event's name to it's listener" do
          engine.listener.expect :handle_event, :retval, [{ event: :name }]

          engine.send_event(:name)

          engine.listener.verify
        end
      end

      describe 'when called with a message' do

        it "sends the event's name and the message to it's listener" do
          engine.listener.expect :handle_event, :retval, [{ event: :name, key1: :value1, key2: :value2 }]

          engine.send_event(:name, key1: :value1, key2: :value2)

          engine.listener.verify
        end
      end
    end

    describe '#handle_start' do

      it 'clears the board' do
        engine.board = ::MiniTest::Mock.new
        engine.board.expect :clear, :retval

        engine.handle_start(:anything)

        engine.board.verify
      end

      it "sets turn to it's argument" do
        engine.handle_start(:anything)
        engine.turn.must_equal :anything
      end

      it 'changes to the playing state' do
        engine.handle_start(:anything)
        engine.state.must_equal engine.playing_state
      end

      it "sends the :game_started event to it's listener" do
        engine.listener = ::MiniTest::Mock.new
        engine.listener.expect :handle_event, :retval, [{ event: :game_started, turn: :x}]

        engine.handle_start(:x)

        engine.listener.verify
      end
    end

    describe '#handle_stop' do

      it "changes to the idle state" do
        engine.handle_stop
        engine.state.must_equal engine.idle_state
      end

      it "sends the :game_stopped event to it's listener" do
        engine.listener = ::MiniTest::Mock.new
        engine.listener.expect :handle_event, :retval, [{ event: :game_stopped }]

        engine.handle_stop

        engine.listener.verify
      end
    end

    describe '#handle_play' do

      describe 'when play goes on as normal' do

        before do
          engine.turn = :x
        end

        it 'does not change state' do
          old_state = engine.state
          engine.handle_play(1, 1)
          engine.state.must_equal old_state
        end

        it "becomes the next player's turn" do
          engine.handle_play(1, 1)
          engine.turn.must_equal :o
        end

        it "sends the :next_turn event to it's listener" do
          engine.listener = ::MiniTest::Mock.new
          engine.listener.expect :handle_event, :retval, [{
            event: :next_turn,
            who: :o,
            last_played_at: OpenStruct.new(row: 1, col: 1)
          }]

          engine.handle_play(1, 1)

          engine.listener.verify
        end
      end

      describe 'when :x wins' do

        before do
          engine.board[1, 1] = engine.board[1, 2] = :x
          engine.board[2, 1] = engine.board[2, 2] = :o
          engine.turn = :x
        end

        it "doesn't change turns" do
          engine.handle_play(1, 3)
          engine.turn.must_equal :x
        end

        it 'changes to the game over state' do
          engine.handle_play(1, 3)
          engine.state.must_equal engine.game_over_state
        end

        it "notifies it's listener that :x has won" do
          engine.listener = ::MiniTest::Mock.new
          engine.listener.expect :handle_event, :retval, [{
            event: :game_over,
            reason: :winner,
            who: :x,
            last_played_at: OpenStruct.new(row: 1, col: 3),
            details: [ { where: :row, index: 1 } ]
          }]

          engine.handle_play(1, 3)

          engine.listener.verify
        end
      end

      describe 'when the game is squashed' do

        before do
          engine.board[1, 1] = engine.board[1, 2] = engine.board[3, 1] = engine.board[3, 3] = :x
          engine.board[2, 1] = engine.board[2, 2] = engine.board[1, 3] = engine.board[3, 2] = :o
          engine.turn = :x
        end

        it "doesn't change turn" do
          engine.handle_play(2, 3)
          engine.turn.must_equal :x
        end

        it 'changes to the game over state' do
          engine.handle_play(2, 3)
          engine.state.must_equal engine.game_over_state
        end

        it "notifies it's listener that the game is squashed" do
          engine.listener = ::MiniTest::Mock.new
          engine.listener.expect :handle_event, :retval, [{
            event: :game_over,
            reason: :squashed,
            who: :x,
            last_played_at: OpenStruct.new(row: 2, col: 3)
          }]

          engine.handle_play(2, 3)

          engine.listener.verify
        end
      end

      describe 'when an invalid move is made' do

        before do
          engine.turn = :o
        end

        describe 'when an out of bounds move is made' do

          it "doesn't change turn" do
            engine.handle_play(0, 1)
            engine.turn.must_equal :o
          end

          it "notifies it's listener that the move was out of bounds" do
            engine.listener = ::MiniTest::Mock.new
            engine.listener.expect :handle_event, :retval, [{ event: :invalid_move, reason: :out_of_bounds }]

            engine.handle_play(0, 1)

            engine.listener.verify
          end
        end

        describe 'when a position is already occupied' do

          before do
            engine.turn = :x
            engine.board[1, 1] = :o
          end

          it "doesn't change turn" do
            engine.handle_play(1, 1)
            engine.turn.must_equal :x
          end

          it "notifies it's listener that the position was occupied" do
            engine.listener = ::MiniTest::Mock.new
            engine.listener.expect :handle_event, :retval, [{ event: :invalid_move, reason: :occupied }]

            engine.handle_play(1, 1)

            engine.listener.verify
          end
        end
      end
    end

    describe '#handle_continue_playing' do

      it 'clears the board' do
        engine.board = ::MiniTest::Mock.new
        engine.board.expect :clear, :retval

        engine.handle_continue_playing(:anything)

        engine.board.verify
      end

      it 'sets turn' do
        engine.handle_continue_playing(:anything)
        engine.turn.must_equal :anything
      end

      it 'changes to the playing state' do
        engine.handle_continue_playing(:anything)
        engine.state.must_equal engine.playing_state
      end

      it "sends the :continue_playing event to it's listener" do
        engine.listener = ::MiniTest::Mock.new
        engine.listener.expect :handle_event, :retval, [{ event: :continue_playing, turn: :x }]

        engine.handle_continue_playing(:x)

        engine.listener.verify
      end
    end

    describe 'its states' do

      it 'has an idle state' do
        engine.idle_state.must_be_instance_of IdleState
      end

      it 'has a playing state' do
        engine.playing_state.must_be_instance_of PlayingState
      end

      it 'has a game over state' do
        engine.game_over_state.must_be_instance_of GameOverState
      end
    end

    describe '#change_to_idle_state' do

      it "changes the engine to it's idle_state" do
        engine.change_to_idle_state
        engine.state.must_equal engine.idle_state
      end
    end

    describe '#change_to_playing_state' do

      it "changes the engine to it's playing state" do
        engine.change_to_playing_state
        engine.state.must_equal engine.playing_state
      end
    end

    describe '#change_to_game_over_state' do

      it "changes the engine to it's game over state" do
        engine.change_to_game_over_state
        engine.state.must_equal engine.game_over_state
      end
    end

    describe 'its state transition methods' do

      let(:state) { engine.state = ::MiniTest::Mock.new }

      describe '#start' do

        it 'invokes #start on state when called with :x' do
          state.expect :start, :retval, [:x]
          engine.start(:x)
          state.verify
        end

        it 'invokes #start on state when called with :o' do
          state.expect :start, :retval, [:o]
          engine.start(:o)
          state.verify
        end

        it 'raises ArgumentError when called with neither :x nor :o' do
          proc { engine.start(:neither_x_nor_o) }.must_raise ArgumentError
        end

        it 'allows chaining' do
          engine.state = engine.idle_state

          engine.start(:x).must_equal engine
        end
      end

      describe '#stop' do

        it 'invokes #stop on state' do
          state.expect :stop, :retval
          engine.stop
          state.verify
        end

        it 'allows chaining' do
          engine.state = engine.playing_state

          engine.stop.must_equal engine
        end
      end

      describe '#play' do

        it 'invokes #play on state' do
          state.expect :play, :retval, [1, 1]
          engine.play(1, 1)
          state.verify
        end

        it 'allows chaining' do
          engine.state = engine.playing_state
          engine.turn = :x

          engine.play(1, 1).must_equal engine
        end
      end

      describe '#continue_playing' do

        it 'invokes #continue_playing on state when called with :x' do
          state.expect :continue_playing, :retval, [:x]
          engine.continue_playing(:x)
          state.verify
        end

        it 'invokes #continue_playing on state when called with :o' do
          state.expect :continue_playing, :retval, [:o]
          engine.continue_playing(:o)
          state.verify
        end

        it 'raises ArgumentError when called with neither :x nor :o' do
          proc { engine.continue_playing(:neither_x_nor_o) }.must_raise ArgumentError
        end

        it 'allows chaining' do
          engine.state = engine.game_over_state

          engine.continue_playing(:x).must_equal engine
        end
      end
    end
  end
end
