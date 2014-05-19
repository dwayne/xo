require 'xo/ai/player'

module XO

  module AI

    class MaxPlayer < Player

      def best_score(next_grids_scores)
        next_grids_scores.max
      end

      def winner_value
        1
      end

      def loser_value
        -1
      end
    end
  end
end
