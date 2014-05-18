require 'xo/ai/player'

module XO

  module AI

    class MinPlayer < Player

      def non_terminal_score(next_grids, scores)
        next_grids_scores(next_grids, scores).min
      end

      def winner_value
        -1
      end

      def loser_value
        1
      end
    end
  end
end
