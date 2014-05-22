require 'state_design_pattern'

require 'xo/grid'
require 'xo/evaluator'
require 'xo/engine/game_context'
require 'xo/engine/init'

module XO

  # The {Engine} encapsulates the game logic for Tic-tac-toe.
  #
  # It is controlled by 4 actions:
  #
  # - start
  # - stop
  # - play
  # - continue_playing
  #
  # Each action may or may not change the state of the engine. This is important
  # because it is the state of the engine that determines when the above actions
  # can be called.
  #
  # The engine can be in 1 of 3 states:
  #
  # - {Init}
  # - {Playing}
  # - {GameOver}
  #
  # The engine begins life in the {Init} state.
  #
  # Here's a table showing which actions can be called in a given state:
  #
  #   State    | Actions
  #   ----------------------------------
  #   Init     | start
  #   Playing  | play, stop
  #   GameOver | continue_playing, stop
  #
  # Each action is defined in their respective state class.
  class Engine < StateDesignPattern::StateMachine

    def start_state
      Init
    end

    def initial_context
      GameContext.new(:nobody, Grid.new)
    end

    def evaluator
      Evaluator.instance
    end
  end
end
