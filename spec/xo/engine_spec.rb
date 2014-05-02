require 'spec_helper'

module XO

  describe Engine do

    let (:engine) { Engine.new }

    describe "its initial state" do

      it "is in the :init state" do
        engine.state.must_equal :init
      end

      it "is nobody's turn" do
        engine.turn.must_equal :nobody
      end

      it "has an empty grid" do
        engine.grid.empty?.must_equal true
      end

      it "has last event set to :new" do
        event = engine.last_event

        event[:name].must_equal :new
      end

      describe "#next_turn" do

        it "returns :nobody" do
          engine.next_turn.must_equal :nobody
        end
      end
    end

    describe "#grid" do

      it "returns a copy of the underlying grid" do
        grid = engine.grid

        grid[1, 1] = Grid::X

        engine.grid.open?(1, 1).must_equal true
      end
    end

    describe "how the state machine works" do

      describe "state :init" do

        it "is in state :init" do
          engine.state.must_equal :init
        end

        describe "#start" do

          before { engine.start(Grid::X) }

          it "changes state to :playing" do
            engine.state.must_equal :playing
          end

          it "sets turn to the value passed in" do
            engine.turn.must_equal Grid::X
          end

          it "starts with an empty grid" do
            engine.grid.empty?.must_equal true
          end

          it "sets last event" do
            event = engine.last_event

            event[:name].must_equal :game_started
          end

          describe "#next_turn" do

            it "returns O" do
              engine.next_turn.must_equal Grid::O
            end
          end
        end

        it "only allows #start to be called" do
          proc { engine.stop }.must_raise Engine::IllegalStateError
          proc { engine.play(1, 1) }.must_raise Engine::IllegalStateError
          proc { engine.continue_playing(Grid::X) }.must_raise Engine::IllegalStateError
        end
      end

      describe "state :playing" do

        before do
          engine.start(Grid::X)
        end

        it "is in state :playing" do
          engine.state.must_equal :playing
        end

        describe "#play" do

          describe "valid moves" do

            describe "when given (1, 1)" do

              before { engine.play(1, 1) }

              it "remains in state :playing" do
                engine.state.must_equal :playing
              end

              it "sets turn to O" do
                engine.turn.must_equal Grid::O
              end

              it "updates the grid at that position" do
                engine.grid[1, 1].must_equal Grid::X
              end

              it "sets last event" do
                event = engine.last_event

                event[:name] = :next_turn
                event[:last_move][:turn] = Grid::X
                event[:last_move][:r] = 1
                event[:last_move][:c] = 1
              end
            end

            describe "when the next move results in the game being over" do

              describe "winning" do

                before do
                  engine.play(1, 1).play(2, 1).play(1, 2).play(2, 2).play(1, 3)
                end

                it "changes state to :game_over" do
                  engine.state.must_equal :game_over
                end

                it "sets turn to the winner" do
                  engine.turn.must_equal Grid::X
                end

                it "leaves the grid unchanged" do
                  engine.grid.inspect.must_equal 'xxxoo    '
                end

                it "sets last event" do
                  event = engine.last_event

                  event[:name] = :game_over
                  event[:type] = :winner
                  event[:last_move][:turn] = Grid::X
                  event[:last_move][:r] = 1
                  event[:last_move][:c] = 3
                  event[:details] = [
                    { where: :row, index: 1, positions: [[1, 1], [1, 2], [1, 3]] }
                  ]
                end
              end

              describe "squashed" do

                before do
                  engine.play(1, 1).play(1, 2).play(1, 3).play(2, 2).play(3, 2).play(2, 1).play(2, 3).play(3, 1).play(3, 3)
                end

                it "changes state to :game_over" do
                  engine.state.must_equal :game_over
                end

                it "leaves turn set to the last one played" do
                  engine.turn.must_equal Grid::X
                end

                it "leaves the grid unchanged" do
                  engine.grid.inspect.must_equal 'xoxooxoxx'
                end

                it "sets last event" do
                  event = engine.last_event

                  event[:name] = :game_over
                  event[:type] = :squashed
                  event[:last_move][:turn] = Grid::X
                  event[:last_move][:r] = 3
                  event[:last_move][:c] = 3
                end
              end
            end
          end

          describe "invalid moves" do

            describe "when given (0, 0)" do

              it "sets last event to out of bounds" do
                event = engine.last_event

                event[:name] = :invalid_move
                event[:type] = :out_of_bounds
              end
            end

            describe "when given (1, 1) and it already has a token there" do

              it "sets last event to occupied" do
                event = engine.last_event

                event[:name] = :invalid_move
                event[:type] = :occupied
              end
            end
          end
        end

        describe "#stop" do

          before { engine.stop }

          it "changes state to :init" do
            engine.state.must_equal :init
          end

          it "sets turn to :nobody" do
            engine.turn.must_equal :nobody
          end

          it "clears the grid" do
            engine.grid.empty?.must_equal true
          end

          it "sets last event" do
            event = engine.last_event

            event[:name].must_equal :game_stopped
          end
        end

        it "only allows #play and #stop to be called" do
          proc { engine.start(Grid::O) }.must_raise Engine::IllegalStateError
          proc { engine.continue_playing(Grid::O) }.must_raise Engine::IllegalStateError
        end
      end

      describe "state :game_over" do

        before do
          engine
            .start(Grid::O)
            .play(1, 1).play(2, 1).play(1, 2).play(2, 2).play(1, 3)
        end

        it "is in state :game_over" do
          engine.state.must_equal :game_over
        end

        describe "#continue_playing" do

          before { engine.continue_playing(Grid::O) }

          it "changes state to :playing" do
            engine.state.must_equal :playing
          end

          it "sets turn to O" do
            engine.turn.must_equal Grid::O
          end

          it "clears the grid" do
            engine.grid.empty?.must_equal true
          end

          it "sets last event" do
            event = engine.last_event

            event[:name].must_equal :game_started
            event[:type].must_equal :continue_playing
          end
        end

        describe "#stop" do

          before { engine.stop }

          it "changes state to :init" do
            engine.state.must_equal :init
          end

          it "sets turn to :nobody" do
            engine.turn.must_equal :nobody
          end

          it "clears the grid" do
            engine.grid.empty?.must_equal true
          end

          it "sets last event" do
            event = engine.last_event

            event[:name].must_equal :game_stopped
          end
        end

        it "only allows #continue_playing and #stop to be called" do
          proc { engine.start(Grid::X) }.must_raise Engine::IllegalStateError
          proc { engine.play(1, 1) }.must_raise Engine::IllegalStateError
        end
      end
    end

    describe "#start with invalid input" do

      it "raises an ArgumentError" do
        proc { engine.start(:invalid_input) }.must_raise ArgumentError
      end
    end

    describe "#continue_playing with invalid input" do

      it "raises an ArgumentError" do
        proc { engine.continue_playing(:invalid_input) }.must_raise ArgumentError
      end
    end
  end
end
