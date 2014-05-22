require 'spec_helper'

class EngineObserver

  def initialize
    @events = []
  end

  def last_event
    @events.last
  end

  def update(event)
    @events << event
  end
end

module XO

  describe Engine do

    let (:engine) { Engine.new }
    let (:engine_observer) { EngineObserver.new }

    describe "how the engine works" do

      before { engine.add_observer(engine_observer) }

      describe "in the Init state" do

        it "is in the Init state" do
          engine.current_state.must_equal Init
        end

        describe "#start" do

          describe "for valid input" do

            before { engine.start(Grid::X) }

            it "is X's turn" do
              engine.turn.must_equal Grid::X
            end

            it "has an empty grid" do
              engine.grid.must_be :empty?
            end

            it "transitions to the Playing state" do
              engine.current_state.must_equal Playing
            end

            it "triggers an event" do
              engine_observer.last_event[:name].must_equal :game_started
            end
          end

          describe "for invalid input" do

            it "raises ArgumentError" do
              proc { engine.start(:nobody) }.must_raise ArgumentError
            end
          end
        end

        it "raises StateDesignPattern::IllegalStateException for the actions stop, play and continue_playing" do
          proc { engine.stop }.must_raise StateDesignPattern::IllegalStateException
          proc { engine.play(1, 1) }.must_raise StateDesignPattern::IllegalStateException
          proc { engine.continue_playing(Grid::X) }.must_raise StateDesignPattern::IllegalStateException
        end
      end

      describe "in the Playing state" do

        before { engine.start(Grid::O) }

        it "is in the Playing state" do
          engine.current_state.must_equal Playing
        end

        describe "#play" do

          describe "when the move is out of bounds" do

            before { engine.play(1, 0) }

            it "remains in the Playing state" do
              engine.current_state.must_equal Playing
            end

            it "triggers an event" do
              last_event = engine_observer.last_event

              last_event[:name].must_equal :invalid_move
              last_event[:type].must_equal :out_of_bounds
            end
          end

          describe "when the move is on an occupied position" do

            before { engine.play(1, 1).play(1, 1) }

            it "remains in the Playing state" do
              engine.current_state.must_equal Playing
            end

            it "triggers an event" do
              last_event = engine_observer.last_event

              last_event[:name].must_equal :invalid_move
              last_event[:type].must_equal :occupied
            end
          end

          describe "when the move results in a win" do

            before do
              engine.play(1, 1).play(2, 1).play(1, 2).play(2, 2).play(1, 3)
            end

            it "transitions to the GameOver state" do
              engine.current_state.must_equal GameOver
            end

            it "triggers an event" do
              last_event = engine_observer.last_event

              last_event[:name].must_equal :game_over
              last_event[:type].must_equal :winner
              last_event[:last_move].must_equal({ turn: Grid::O, r: 1, c: 3 })
              last_event[:details][0][:where].must_equal :row
              last_event[:details][0][:index].must_equal 1
            end
          end

          describe "when the move results in a squashed game" do

            before do
              engine
                .play(1, 1).play(2, 2)
                .play(3, 3).play(1, 2)
                .play(3, 2).play(3, 1)
                .play(1, 3).play(2, 3)
                .play(2, 1)
            end

            it "transitions to the GameOver state" do
              engine.current_state.must_equal GameOver
            end

            it "triggers an event" do
              last_event = engine_observer.last_event

              last_event[:name].must_equal :game_over
              last_event[:type].must_equal :squashed
              last_event[:last_move].must_equal({ turn: Grid::O, r: 2, c: 1 })
            end
          end

          describe "when the move just advances the game" do

            before { engine.play(1, 1) }

            it "sets O at position (1, 1)" do
              engine.grid[1, 1].must_equal Grid::O
            end

            it "remains in the Playing state" do
              engine.current_state.must_equal Playing
            end

            it "triggers an event" do
              last_event = engine_observer.last_event

              last_event[:name].must_equal :next_turn
              last_event[:last_move].must_equal({ turn: Grid::O, r: 1, c: 1 })
            end
          end
        end

        describe "#stop" do

          before { engine.play(2, 2).play(3, 1).stop }

          it "resets the game" do
            engine.turn.must_equal :nobody
            engine.grid.must_be :empty?
          end

          it "transitions to the Init state" do
            engine.current_state.must_equal Init
          end

          it "triggers an event" do
            engine_observer.last_event[:name].must_equal :game_stopped
          end
        end

        it "raises StateDesignPattern::IllegalStateException for the actions start and continue_playing" do
          proc { engine.start(Grid::X) }.must_raise StateDesignPattern::IllegalStateException
          proc { engine.continue_playing(Grid::X) }.must_raise StateDesignPattern::IllegalStateException
        end
      end

      describe "in the GameOver state" do

        before do
          engine
            .start(Grid::X)
            .play(1, 1).play(2, 1).play(1, 2).play(2, 2).play(1, 3)
        end

        it "is in the GameOver state" do
          engine.current_state.must_equal GameOver
        end

        describe "#continue_playing" do

          before { engine.continue_playing(Grid::X) }

          it "is X's turn" do
            engine.turn.must_equal Grid::X
          end

          it "has an empty grid" do
            engine.grid.must_be :empty?
          end

          it "transitions to the Playing state" do
            engine.current_state.must_equal Playing
          end

          it "triggers an event" do
            last_event = engine_observer.last_event

            last_event[:name].must_equal :game_started
            last_event[:type].must_equal :continue_playing
          end
        end

        describe "#stop" do

          before { engine.stop }

          it "resets the game" do
            engine.turn.must_equal :nobody
            engine.grid.must_be :empty?
          end

          it "transitions to the Init state" do
            engine.current_state.must_equal Init
          end

          it "triggers an event" do
            engine_observer.last_event[:name].must_equal :game_stopped
          end
        end

        it "raises StateDesignPattern::IllegalStateException for the actions start and play" do
          proc { engine.start(Grid::X) }.must_raise StateDesignPattern::IllegalStateException
          proc { engine.play(1, 1) }.must_raise StateDesignPattern::IllegalStateException
        end
      end
    end
  end
end
